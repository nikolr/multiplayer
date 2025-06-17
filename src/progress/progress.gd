class_name Progress extends HSlider

@export var dual_audio_server: DualAudioServer

var dragging: bool = false

func _ready() -> void:
	drag_started.connect(_on_drag_started)

func _process(delta: float) -> void:
	if dual_audio_server.currently_in_use.stream and dual_audio_server.currently_in_use.playing and not dragging:
		var progress: float = dual_audio_server.currently_in_use.get_playback_position() / dual_audio_server.currently_in_use.stream.get_length()
		value = progress * 100

func _on_drag_started() -> void:
	dragging = true
