extends HTTPRequest

class_name NetworkManager

const host = "godot-firebase-test-game-default-rtdb.europe-west1.firebasedatabase.app"

func get_player_url(player_id: String) -> String:
	var rel_path = "/players/%s.json" % player_id
	return "https://" + host + rel_path

func write_player(player: PlayerData) -> void:
	var url = get_player_url(player.player_id)
	request(url, [], HTTPClient.METHOD_PUT, JSON.stringify(player.to_dict()))
	await request_completed

func _setup_tcp_stream() -> StreamPeerTCP:
	var tcp = StreamPeerTCP.new()
	
	var err_conn_tcp = tcp.connect_to_host(host, 443)
	assert(err_conn_tcp == OK)
	
	tcp.poll()
	var tcp_status = tcp.get_status()
	while tcp_status == StreamPeerTCP.STATUS_CONNECTING:
		await get_tree().process_frame
		tcp.poll()
		tcp_status = tcp.get_status()

	assert(tcp_status == StreamPeerTCP.STATUS_CONNECTED)
	
	return tcp

func _setup_tls_stream(tcp: StreamPeerTCP) -> StreamPeerTLS:
	var stream = StreamPeerTLS.new()
	var err_conn_stream = stream.connect_to_stream(tcp, host, TLSOptions.client())
	assert(err_conn_stream == OK)
	
	stream.poll()
	var stream_status = stream.get_status()
	while stream_status != StreamPeerTLS.STATUS_CONNECTED:
		await get_tree().process_frame
		stream.poll()
		stream_status = stream.get_status()
	
	return stream

func _start_sse_stream(stream: StreamPeerTLS) -> void:
	var url = "https://" + host + "/players.json"
	var request = "GET %s HTTP/1.1\n" % url
	request += "Host: %s\n" % host
	request += "Accept: text/event-stream\n\n"
	stream.put_data(request.to_utf8_buffer())

func _read_stream_response(stream: StreamPeerTLS) -> String:
	stream.poll()
	var available_bytes = stream.get_available_bytes()
	while available_bytes == 0:
		await get_tree().process_frame
		stream.poll()
		available_bytes = stream.get_available_bytes()
	
	var data: Array = stream.get_partial_data(available_bytes)
	
	var err = data[0]
	assert(err == OK)
	
	var response = data[1].get_string_from_utf8()
	return response

func _parse_server_event(event_string: String) -> Array[PlayerData]:
	return []

func start_player_stream(player_callback: Callable) -> void:
	var tcp = await _setup_tcp_stream()
	var stream = await _setup_tls_stream(tcp)
	
	# send request for server-sent event stream and wait for first message
	_start_sse_stream(stream)
	var initial_response = await _read_stream_response(stream)
	print("Initial response: \n %s \n" % initial_response)
	
	while true:
		var response = await _read_stream_response(stream)
		var players = _parse_server_event(response)
		player_callback.call(players)
