class_name Volume extends HSlider

@export var track_ui: TrackUi

func _ready() -> void:
	drag_ended.connect(_on_volume_slider_dragged)

func _on_volume_slider_dragged(value_changed: bool) -> void:
	if value_changed:
		track_ui.track.volume = value
		if track_ui.currently_playing:
			Events.volume_changed.emit(track_ui)
