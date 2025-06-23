class_name MasterVolumeSlider extends VBoxContainer

@export var h_slider: HSlider

func _ready() -> void:
	var audio_settings: Dictionary = ConfigFileHandler.load_settings(ConfigFileHandler.SettingSection.AUDIO)
	h_slider.value = min(audio_settings.master_volume, 100.0)
	h_slider.drag_ended.connect(_on_volume_slider_dragged)

func _on_volume_slider_dragged(value_changed: bool) -> void:
	if value_changed:
		AudioServer.set_bus_volume_linear(0, h_slider.value / 100.0)
		ConfigFileHandler.save_audio_setting(ConfigFileHandler.AudioSetting.MASTER_VOLUME, h_slider.value)
