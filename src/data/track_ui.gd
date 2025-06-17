class_name TrackUi extends Control

@export var track: Track
@export var button: Button
@export var label: Label

@export var up_button: Button
@export var down_button: Button

func set_track(t: Track) -> void:
	track = t
	label.text = t.filename
