class_name Main extends Node

#region Exports
@export var select_file_button: Button
@export var file_dialog: FileDialog
@export var audio_stream_player: AudioStreamPlayer
@export var track_list: VBoxContainer
@export var progress: Progress
@export var previous_button: Button
@export var play_button: Button
@export var pause_button: Button
#endregion

#region Constants
const TRACK = preload("res://src/data/track_ui.tscn")
#endregion

#region Global
var playback_position: float = 0.0
var audio_queue: Array[Track]
#endregion

func _ready() -> void:
	select_file_button.pressed.connect(_on_select_file_button_pressed)
	file_dialog.file_selected.connect(_on_file_selected)
	previous_button.pressed.connect(_on_previous_button_pressed)
	play_button.pressed.connect(_on_play_button_pressed)
	pause_button.pressed.connect(_on_pause_button_pressed)
	
	progress.drag_ended.connect(_on_progress_slider_dragged)
	
	audio_stream_player.finished.connect(_on_audio_stream_player_finished)

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
	track_list.add_child(track_ui)
	if not audio_stream_player.stream:
		var primary_track = audio_queue[0]
		audio_stream_player.stream = primary_track.stream
	print(audio_queue)

func _on_previous_button_pressed() -> void:
	playback_position = 0.0
	if audio_stream_player.playing:
		audio_stream_player.play(playback_position)

func _on_play_button_pressed() -> void:
	if audio_stream_player.stream and not audio_stream_player.playing:
		audio_stream_player.play(playback_position)

func _on_pause_button_pressed() -> void:
	if audio_stream_player.stream and audio_stream_player.playing:
		playback_position = audio_stream_player.get_playback_position()
		audio_stream_player.stop()

func _on_track_play_button_pressed(track_ui: TrackUi) -> void:
	if audio_stream_player.playing:
		playback_position = audio_stream_player.get_playback_position()
	audio_stream_player.stream = track_ui.track.stream
	#audio_queue.erase(track_ui.track)
	#audio_queue.push_front(track_ui.track)
	audio_stream_player.play(playback_position)

func _on_progress_slider_dragged(value_changed: bool) -> void:
	progress.dragging = false
	if not audio_stream_player.stream:
		return
	print(progress.value)
	print(audio_stream_player.stream.get_length())
	if audio_stream_player.playing and value_changed:
		playback_position = (progress.value / 100.0) * audio_stream_player.stream.get_length()
		audio_stream_player.seek(playback_position)

func _on_audio_stream_player_finished() -> void:
	playback_position = 0.0
	audio_stream_player.play(playback_position)
