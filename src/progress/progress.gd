class_name Progress extends HSlider

@export var audio_stream_player: AudioStreamPlayer

func _process(delta: float) -> void:
	if audio_stream_player.stream:
		var progress: float = audio_stream_player.get_playback_position() / audio_stream_player.stream.get_length()
		value = progress * 100
