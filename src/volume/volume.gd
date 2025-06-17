class_name Volume extends Control

@onready var label: Label = $Label
@onready var h_slider: HSlider = $HSlider

func _ready() -> void:
	h_slider.drag_ended.connect(_on_volume_slider_dragged)

func _on_volume_slider_dragged(value_changed: bool) -> void:
	if value_changed:
		AudioServer.set_bus_volume_linear(0, h_slider.value / 100.0)
