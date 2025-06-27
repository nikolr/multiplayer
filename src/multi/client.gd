extends Control

@export var connect_button: Button
@export var disconnect_button: Button
@export var ip_text_edit: TextEdit
@export var username_text_edit: TextEdit
@export var connection_status: Label

var multiplayer_peer = ENetMultiplayerPeer.new()
const PORT = 9475


func _ready():
	connect_button.pressed.connect(_on_connect_button_pressed)
	disconnect_button.pressed.connect(_on_disconnect_button_pressed)
	
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	update_connection_buttons()

func _on_connect_button_pressed() -> void:
	print("Connecting ...")
	# Add error handling here
	var err = multiplayer_peer.create_client(ip_text_edit.text, PORT)
	print("Using port: ", PORT, " and IP: ", ip_text_edit.text ," for connection")
	print("ERR: ", err)
	multiplayer.multiplayer_peer = multiplayer_peer
	update_connection_buttons()
	var i = 0
	# Godot internally has hardcoded 30s timeout
	while true and i<32:
		if multiplayer_peer.get_connection_status() == MultiplayerPeer.ConnectionStatus.CONNECTION_CONNECTED:
			connection_status.text = "Connected"
			break
		else:
			connection_status.text = "Connecting..."
			i += 1
			await get_tree().create_timer(1).timeout
	update_connection_buttons()

func _on_connected_to_server() -> void:
	rpc_id(1, "register_client", multiplayer_peer.get_unique_id(), username_text_edit.text)

func _on_connection_failed() -> void:
	update_connection_buttons()

func _on_disconnect_button_pressed():
	multiplayer_peer.close()
	update_connection_buttons()
	print("Disconnected.")

func _on_server_disconnected():
	multiplayer_peer.close()
	update_connection_buttons()
	print("Connection to server lost.")

func update_connection_buttons() -> void:
	print("Updating buttons")
	if multiplayer_peer.get_connection_status() == multiplayer_peer.CONNECTION_DISCONNECTED:
		connection_status.text = "Disconnected"
		connect_button.disabled = false
		disconnect_button.disabled = true
	if multiplayer_peer.get_connection_status() == multiplayer_peer.CONNECTION_CONNECTING:
		connection_status.text = "Connecting..."
		connect_button.disabled = true
		disconnect_button.disabled = true
	if multiplayer_peer.get_connection_status() == multiplayer_peer.CONNECTION_CONNECTED:
		connection_status.text = "Connected"
		connect_button.disabled = true
		disconnect_button.disabled = false

@rpc("any_peer", "reliable")
func register_client() -> void:
	pass
