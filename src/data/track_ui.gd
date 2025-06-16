class_name TrackUi extends Control

@export var track: Track
@export var button: Button
@export var label: Label

func set_track(t: Track) -> void:
	track = t
	label.text = t.filename
