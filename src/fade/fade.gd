class_name Fade extends Control

@export var duration_label: Label
@export var fade_slider: HSlider

func _ready() -> void:
	fade_slider.drag_ended.connect(_on_fade_slider_drag_ended)

func _on_fade_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		duration_label.text = str(fade_slider.value)
