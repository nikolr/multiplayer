class_name Progress extends HSlider

@export var audio_stream_player: AudioStreamPlayer

var dragging: bool = false

func _ready() -> void:
	drag_started.connect(_on_drag_started)

func _process(delta: float) -> void:
	if audio_stream_player.stream and not dragging:
		var progress: float = audio_stream_player.get_playback_position() / audio_stream_player.stream.get_length()
		value = progress * 100

func _on_drag_started() -> void:
	dragging = true
