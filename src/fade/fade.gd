class_name Fade extends Control

enum InOrOut {
	IN,
	OUT,
} 

@export var duration_label: Label
@export var fade_slider: HSlider
@export var in_or_out: InOrOut

func _ready() -> void:
	var audio_settings: Dictionary = ConfigFileHandler.load_settings(ConfigFileHandler.SettingSection.AUDIO)
	match in_or_out:
		InOrOut.IN:
			fade_slider.value = min(audio_settings.fade_in_duration, 5.0)
		InOrOut.OUT:
			fade_slider.value = min(audio_settings.fade_out_duration, 5.0)
	duration_label.text = str(fade_slider.value)
	fade_slider.drag_ended.connect(_on_fade_slider_drag_ended)

func _on_fade_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		duration_label.text = str(fade_slider.value)
		match in_or_out:
			InOrOut.IN:
				ConfigFileHandler.save_audio_setting(ConfigFileHandler.AudioSetting.FADE_IN_DURATION, fade_slider.value)
			InOrOut.OUT:
				ConfigFileHandler.save_audio_setting(ConfigFileHandler.AudioSetting.FADE_OUT_DURATION, fade_slider.value)
