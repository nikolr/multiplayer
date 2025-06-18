class_name DualAudioServer extends Node

@export var fade_out_slider: Fade
@export var fade_in_slider: Fade
@export var primary_audio_server: AudioStreamPlayer
@export var secondary_audio_server: AudioStreamPlayer

var currently_in_use: AudioStreamPlayer

func _ready() -> void:
	currently_in_use = primary_audio_server

func switch_currently_in_use() -> void:
	if currently_in_use == primary_audio_server:
		currently_in_use = secondary_audio_server
	else:
		currently_in_use = primary_audio_server

func get_not_in_use() -> AudioStreamPlayer:
	if currently_in_use == primary_audio_server:
		return secondary_audio_server
	else:
		return primary_audio_server

func transition(track_ui: TrackUi) -> void:
	print("In use: ", currently_in_use)
	var fade_out_duration: float = fade_out_slider.fade_slider.value
	var fade_in_duration: float = fade_in_slider.fade_slider.value
	var tween: Tween = create_tween()
	tween.tween_property(currently_in_use, "volume_linear", 0.0, fade_out_duration).from_current()
	get_not_in_use().stream = track_ui.track.stream
	print(track_ui.track.volume)
	tween.tween_callback(AudioServer.set_bus_volume_linear.bind(0, track_ui.track.volume))
	tween.tween_property(get_not_in_use(), "volume_linear", track_ui.track.volume, fade_in_duration).from_current()
	tween.connect("finished", on_tween_finished)
	switch_currently_in_use()
	print(currently_in_use.volume_linear)
	print("In use: ", currently_in_use)

func on_tween_finished() -> void:
	get_not_in_use().seek(0)
