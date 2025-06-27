class_name ModeSelect extends Control

const CLIENT = preload("res://src/multi/client.tscn")
const MAIN = preload("res://src/main.tscn")

@export var host_button: Button
@export var client_button: Button
@export var local_button: Button

func _ready() -> void:
	host_button.pressed.connect(_on_host_button_pressed)
	client_button.pressed.connect(_on_client_button_pressed)
	local_button.pressed.connect(_on_local_button_pressed)
	
	#match ConfigFileHandler.load_mode_setting():
		#ConfigFileHandler.Mode.HOST:
			#get_tree().change_scene_to_packed(MAIN)
		#ConfigFileHandler.Mode.CLIENT:
			#get_tree().change_scene_to_packed(CLIENT)
		#ConfigFileHandler.Mode.LOCAL:
			#get_tree().change_scene_to_packed(MAIN)

func _on_host_button_pressed() -> void:
	ConfigFileHandler.save_mode_setting(ConfigFileHandler.Mode.HOST)
	get_tree().change_scene_to_packed(MAIN)

func _on_client_button_pressed() -> void:
	ConfigFileHandler.save_mode_setting(ConfigFileHandler.Mode.CLIENT)
	get_tree().change_scene_to_packed(CLIENT)

func _on_local_button_pressed() -> void:
	ConfigFileHandler.save_mode_setting(ConfigFileHandler.Mode.LOCAL)
	get_tree().change_scene_to_packed(MAIN)
