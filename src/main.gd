class_name Main extends Node

#region Exports
@export var select_file_button: Button
@export var volume: Volume
@export var currently_playing_track_label: Label
@export var file_dialog: FileDialog
@export var dual_audio_server: DualAudioServer
@export var track_list: VBoxContainer
@export var progress: Progress
@export var previous_button: Button
@export var pause_button: Button

#endregion

#region Constants
const TRACK = preload("res://src/data/track_ui.tscn")
#endregion

#region Global
var playback_position: float = 0.0
var audio_queue: Array[Track]
var transitioning: bool = false
#endregion

func _ready() -> void:
	select_file_button.pressed.connect(_on_select_file_button_pressed)
	file_dialog.file_selected.connect(_on_file_selected)
	file_dialog.files_selected.connect(_on_files_selected)
	previous_button.pressed.connect(_on_previous_button_pressed)
	pause_button.pressed.connect(_on_pause_button_pressed)
	
	progress.drag_ended.connect(_on_progress_slider_dragged)
	
	dual_audio_server.primary_audio_server.finished.connect(_on_dual_audio_server_finished.bind(dual_audio_server.primary_audio_server))
	dual_audio_server.secondary_audio_server.finished.connect(_on_dual_audio_server_finished.bind(dual_audio_server.secondary_audio_server))

func _on_select_file_button_pressed() -> void:
	file_dialog.show()

func _on_file_selected(path: String) -> void:
	print(path)
	var track: Track = Track.create(path)
	#track.stream.loop = true
	audio_queue.append(track)
	var track_ui: TrackUi = TRACK.instantiate()
	track_ui.set_track(track)
	track_ui.button.pressed.connect(_on_track_play_button_pressed.bind(track_ui))
	track_ui.up_button.pressed.connect(_on_up_button_pressed.bind(track_ui))
	track_ui.down_button.pressed.connect(_on_down_button_pressed.bind(track_ui))
	track_ui.remove_button.pressed.connect(_on_remove_button_pressed.bind(track_ui))
	
	track_list.add_child(track_ui)
	if not dual_audio_server.currently_in_use.stream:
		var primary_track = audio_queue[0]
		dual_audio_server.currently_in_use.stream = primary_track.stream
	print(audio_queue)

func _on_files_selected(paths: PackedStringArray) -> void:
	pass

func _on_remove_button_pressed(track_ui: TrackUi) -> void:
	track_ui.button.pressed.disconnect(_on_track_play_button_pressed.bind(track_ui))
	track_ui.up_button.pressed.disconnect(_on_up_button_pressed.bind(track_ui))
	track_ui.down_button.pressed.disconnect(_on_down_button_pressed.bind(track_ui))
	track_ui.remove_button.pressed.disconnect(_on_remove_button_pressed.bind(track_ui))
	track_list.remove_child(track_ui)
	if dual_audio_server.currently_in_use.stream == track_ui.track.stream:
		playback_position = dual_audio_server.currently_in_use.get_playback_position()
		dual_audio_server.currently_in_use.stop()

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
		playback_position = dual_audio_server.currently_in_use.get_playback_position()
		dual_audio_server.currently_in_use.stop()

func _on_track_play_button_pressed(track_ui: TrackUi) -> void:
	if dual_audio_server.currently_in_use.playing:
		playback_position = dual_audio_server.currently_in_use.get_playback_position()
	dual_audio_server.transition(track_ui)
	currently_playing_track_label.text = "Now playing: " + track_ui.track.filename
	print("Playback position: ", playback_position)
	dual_audio_server.currently_in_use.play(playback_position)
	for t: TrackUi in track_list.get_children():
		t.panel.hide()
	#dual_audio_server.currently_in_use.stream = track_ui.track.stream
	#currently_playing_track_label.text = "Now playing: " + track_ui.track.filename
	#dual_audio_server.currently_in_use.play(playback_position)
	track_ui.panel.show()

func _change_streams(stream: AudioStreamMP3) -> void:
	dual_audio_server.currently_in_use.stream = stream

func _on_progress_slider_dragged(value_changed: bool) -> void:
	progress.dragging = false
	if not dual_audio_server.currently_in_use.stream:
		return
	print(progress.value)
	print(dual_audio_server.currently_in_use.stream.get_length())
	if dual_audio_server.currently_in_use.playing and value_changed:
		playback_position = (progress.value / 100.0) * dual_audio_server.currently_in_use.stream.get_length()
		dual_audio_server.currently_in_use.seek(playback_position)

func _on_dual_audio_server_finished(server: AudioStreamPlayer) -> void:
	print("Server finished")
	playback_position = 0.0
	server.play(playback_position)
