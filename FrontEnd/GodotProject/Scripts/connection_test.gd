extends Node

var web_socket_server:WebSocketServer
var players : Dictionary = {}

func _ready() -> void:
	web_socket_server = WebSocketServer.new()
	add_child(web_socket_server)
	
	_connect_signals()
	
	var port = 12345
	var error = web_socket_server.listen(port)
	
	if error == OK:
		print("WebSocket Server is running on port %d" % port)
	else:
		print("WebSocket Server failed to start on port %d. Error: %d" % [port, error])
	
	set_process(true)

func _process(delta: float) -> void:
	web_socket_server.poll()


func _connect_signals():
	web_socket_server.message_received.connect(_on_message_received)
	web_socket_server.client_connected.connect(_on_client_connected)
	web_socket_server.client_disconnected.connect(_on_client_disconnected)

func _on_message_received(peer_id : int, message):
	var json = JSON.new()
	json.parse(message)
	var data = json.data
	match data.action:
		"join":
			add_new_player(peer_id, data.user)


func _on_client_connected(peer_id : int):
	print("Client %d connected" % peer_id)


func _on_client_disconnected(peer_id : int):
	print("Client %d disconnected" % peer_id)
	remove_player(peer_id)


func add_new_player(peer_id : int, username : String):
	get_parent().add_new_player(username)


func remove_player(peer_id : int):
	var player = players.get(peer_id)
	if player:
		print("%s has left the game." % player.username)
		players.erase(peer_id)
