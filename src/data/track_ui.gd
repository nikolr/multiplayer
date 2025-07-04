class_name TrackUi extends Control

@export var track: Track
@export var button: Button
@export var label: Label
@export var panel: Panel
@export var volume: Volume

@export var remove_button: Button
@export var up_button: Button
@export var down_button: Button

var currently_playing: bool = false

func set_track(t: Track) -> void:
	track = t
	label.text = t.filename
	volume.value = t.volume
