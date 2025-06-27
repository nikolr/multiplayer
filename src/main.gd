class_name Main extends Node

#region Exports
@export var select_file_button: Button
@export var currently_playing_track_label: Label
@export var file_dialog: FileDialog
@export var playlist_export_file_dialog: FileDialog
@export var playlist_import_file_dialog: FileDialog
@export var export_button: Button
@export var import_button: Button
@export var dual_audio_server: DualAudioServer
@export var track_list: VBoxContainer
@export var progress: Progress
@export var previous_button: Button
@export var pause_button: Button
@export var hostt: Host

#endregion

#region Constants
const TRACK = preload("res://src/data/track_ui.tscn")
#endregion

#region Global
var playback_position: float = 0.0
var transitioning: bool = false
var mode: ConfigFileHandler.Mode
#endregion

#region Multiplayer
signal upnp_completed(error)
var thread: Thread = null
var multiplayer_peer = ENetMultiplayerPeer.new()
var upnp = UPNP.new()

const PORT = 9475

var connected_peers: Array[Peer] = []
#endregion

func _ready() -> void:
	mode = ConfigFileHandler.load_mode_setting()
	match mode:
		ConfigFileHandler.Mode.LOCAL:
			hostt.hide()
		ConfigFileHandler.Mode.HOST:
			hostt.show()
			# Connect signals here
	print(mode)
	
	tree_exited.connect(_on_tree_exited)
	upnp_completed.connect(_on_upnp_completed)
	select_file_button.pressed.connect(_on_select_file_button_pressed)
	export_button.pressed.connect(_on_export_button_pressed)
	import_button.pressed.connect(_on_import_button_pressed)
	file_dialog.file_selected.connect(_on_file_selected)
	file_dialog.files_selected.connect(_on_files_selected)
	playlist_export_file_dialog.file_selected.connect(_on_playlist_saved)
	playlist_import_file_dialog.file_selected.connect(_on_playlist_selected)
	previous_button.pressed.connect(_on_previous_button_pressed)
	pause_button.pressed.connect(_on_pause_button_pressed)
	
	progress.drag_ended.connect(_on_progress_slider_dragged)
	
	dual_audio_server.primary_audio_server.finished.connect(_on_dual_audio_server_finished.bind(dual_audio_server.primary_audio_server))
	dual_audio_server.secondary_audio_server.finished.connect(_on_dual_audio_server_finished.bind(dual_audio_server.secondary_audio_server))
	
	setup_server()


func setup_server() -> void:
	thread = Thread.new()
	thread.start(forward_port)
	
	var err = multiplayer_peer.create_server(PORT)
	multiplayer_peer
	print("This is err: ", err)
	multiplayer.multiplayer_peer = multiplayer_peer
	#multiplayer_peer.peer_connected.connect(_on_peer_connected)
	multiplayer_peer.peer_disconnected.connect(_on_peer_disconnected)
	print("Server is up and running.")

func forward_port() -> void:
	var err = upnp.discover()
	print(err)
	if err != OK:
		push_error(str(err))
		upnp_completed.emit(err)
		return
	
	for i in range(upnp.get_device_count()):
		print("Device found: ", upnp.get_device(i))
	print("Gateway: ", upnp.get_gateway())
	print("ADDR: ", upnp.query_external_address())
	
	if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
		print("DID this")
		var udp_res = upnp.add_port_mapping(PORT, PORT, ProjectSettings.get_setting("application/config/name"), "UDP")
		print(udp_res)
		var gateway_udp_res = upnp.get_gateway().add_port_mapping(PORT, PORT, ProjectSettings.get_setting("application/config/name"), "UDP")
		print(gateway_udp_res)
		var tcp_res = upnp.add_port_mapping(PORT, PORT, ProjectSettings.get_setting("application/config/name"), "TCP")
		print(tcp_res)
		var gateway_tcp_res = upnp.get_gateway().add_port_mapping(PORT, PORT, ProjectSettings.get_setting("application/config/name"), "TCP")
		print(gateway_tcp_res)

func _on_playlist_saved(path: String) -> void:
	var tracks: Array[Track] = []
	for t in track_list.get_children():
		tracks.append(t.track)
	var playlist: Playlist = Playlist.new()
	playlist.track_list = tracks
	var playlist_array: Array = []
	for t: Track in playlist.track_list:
		var t_dict = {}
		t_dict[t.path] = t.volume
		playlist_array.append(t_dict)
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(playlist_array))
	file.close()

func _on_playlist_selected(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	var playlist = JSON.parse_string(file.get_as_text())
	for t in track_list.get_children():
		_remove_track(t)
	dual_audio_server.currently_in_use.stop()
	currently_playing_track_label.text = ""
	playback_position = 0.0
	progress.value = playback_position
	for p in playlist:
		var track: Track = Track.create(p.keys()[0])
		track.volume = p.values()[0]
		_on_file_selected_from_playlist(track)

func _on_select_file_button_pressed() -> void:
	file_dialog.show()

func _on_export_button_pressed() -> void:
	playlist_export_file_dialog.show()

func _on_import_button_pressed() -> void:
	playlist_import_file_dialog.show()

func _on_file_selected(path: String) -> void:
	var track: Track = Track.create(path)
	var track_ui: TrackUi = TRACK.instantiate()
	track_ui.set_track(track)
	track_ui.button.pressed.connect(_on_track_play_button_pressed.bind(track_ui))
	track_ui.up_button.pressed.connect(_on_up_button_pressed.bind(track_ui))
	track_ui.down_button.pressed.connect(_on_down_button_pressed.bind(track_ui))
	track_ui.remove_button.pressed.connect(_on_remove_button_pressed.bind(track_ui))
	
	track_list.add_child(track_ui)

func _on_file_selected_from_playlist(track: Track) -> void:
	var track_ui: TrackUi = TRACK.instantiate()
	track_ui.set_track(track)
	track_ui.button.pressed.connect(_on_track_play_button_pressed.bind(track_ui))
	track_ui.up_button.pressed.connect(_on_up_button_pressed.bind(track_ui))
	track_ui.down_button.pressed.connect(_on_down_button_pressed.bind(track_ui))
	track_ui.remove_button.pressed.connect(_on_remove_button_pressed.bind(track_ui))
	
	track_list.add_child(track_ui)

func _on_files_selected(paths: PackedStringArray) -> void:
	for path: String in paths:
		_on_file_selected(path)

func _on_files_selected_from_playlist(tracks: Array[Track]) -> void:
	for t: Track in tracks:
		_on_file_selected_from_playlist(t)

func _on_remove_button_pressed(track_ui: TrackUi) -> void:
	_remove_track(track_ui)
	if dual_audio_server.currently_in_use.stream == track_ui.track.stream:
		playback_position = dual_audio_server.currently_in_use.get_playback_position()
		dual_audio_server.currently_in_use.stop()

func _remove_track(track_ui: TrackUi) -> void:
	track_ui.button.pressed.disconnect(_on_track_play_button_pressed.bind(track_ui))
	track_ui.up_button.pressed.disconnect(_on_up_button_pressed.bind(track_ui))
	track_ui.down_button.pressed.disconnect(_on_down_button_pressed.bind(track_ui))
	track_ui.remove_button.pressed.disconnect(_on_remove_button_pressed.bind(track_ui))
	track_list.remove_child(track_ui)
	if track_list.get_child_count() == 0:
		playback_position = 0.0

func _on_up_button_pressed(track_ui: TrackUi) -> void:
	var position_in_track_list: int = track_list.get_children().find(track_ui)
	if position_in_track_list == 0:
		return
	track_list.move_child(track_ui, position_in_track_list - 1)

func _on_down_button_pressed(track_ui: TrackUi) -> void:
	var position_in_track_list: int = track_list.get_children().find(track_ui)
	if position_in_track_list == track_list.get_child_count():
		return
	track_list.move_child(track_ui, position_in_track_list + 1)

func _on_previous_button_pressed() -> void:
	playback_position = 0.0
	if dual_audio_server.currently_in_use.playing:
		dual_audio_server.currently_in_use.play(playback_position)

func _on_pause_button_pressed() -> void:
	if dual_audio_server.currently_in_use.stream and dual_audio_server.currently_in_use.playing:
		currently_playing_track_label.text = "Paused..."
		playback_position = dual_audio_server.currently_in_use.get_playback_position()
		dual_audio_server.currently_in_use.stop()

func _on_track_play_button_pressed(track_ui: TrackUi) -> void:
	if dual_audio_server.transitioning:
		return
	if dual_audio_server.currently_in_use.playing:
		playback_position = dual_audio_server.currently_in_use.get_playback_position()
		dual_audio_server.transition(track_ui)
		currently_playing_track_label.text = "Now playing: " + track_ui.track.filename
		dual_audio_server.currently_in_use.play(playback_position)
		for t: TrackUi in track_list.get_children():
			if t.panel.visible:
				t.currently_playing = false
			t.panel.hide()
		track_ui.panel.show()
		track_ui.currently_playing = true
	else:
		dual_audio_server.currently_in_use.stream = track_ui.track.stream
		currently_playing_track_label.text = "Now playing: " + track_ui.track.filename
		Events.volume_changed.emit(track_ui)
		dual_audio_server.currently_in_use.play(playback_position)
		for t: TrackUi in track_list.get_children():
			if t.panel.visible:
				t.currently_playing = false
			t.panel.hide()
		track_ui.panel.show()
		track_ui.currently_playing = true

func _change_streams(stream: AudioStream) -> void:
	dual_audio_server.currently_in_use.stream = stream

func _on_progress_slider_dragged(value_changed: bool) -> void:
	progress.dragging = false
	if not dual_audio_server.currently_in_use.stream:
		return
	if dual_audio_server.currently_in_use.playing and value_changed:
		playback_position = (progress.value / 100.0) * dual_audio_server.currently_in_use.stream.get_length()
		dual_audio_server.currently_in_use.seek(playback_position)

func _on_dual_audio_server_finished(server: AudioStreamPlayer) -> void:
	playback_position = 0.0
	server.play(playback_position)

#region Multiplayer
@rpc("any_peer", "reliable")
func register_client(id: int, username: String) -> void:
	print(id)
	print(username)
	var peer: Peer = Peer.new()
	peer.id = id
	peer.username = username
	connected_peers.append(peer)
	hostt.add_client(peer)

func _on_peer_disconnected(leaving_peer_id : int) -> void:
	# The disconnect signal fires before the client is removed from the connected
	# clients in multiplayer.get_peers(), so we wait for a moment.
	await get_tree().create_timer(1).timeout 
	remove_player(leaving_peer_id)

func remove_player(leaving_peer_id : int) -> void:
	var peer_idx_in_peer_list : int
	for i in range(connected_peers.size()):
		if connected_peers[i].id == leaving_peer_id:
			peer_idx_in_peer_list = i
			break
	var removed_peer: Peer
	if peer_idx_in_peer_list != -1:
		removed_peer = connected_peers.pop_at(peer_idx_in_peer_list)
	hostt.remove_client(removed_peer)
	print("Player " + str(leaving_peer_id) + " disconnected.")
#endregion

func _on_tree_exited() -> void:
	thread.wait_to_finish()

func _on_upnp_completed(err: UPNP.UPNPResult) -> void:
	thread.wait_to_finish()
