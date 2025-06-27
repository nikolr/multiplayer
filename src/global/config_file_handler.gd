extends Node

#region Setting Constants
enum SettingSection {
	AUDIO,
	MODE,
}

const SECTION_NAMES: Dictionary[SettingSection, String] = {
	SettingSection.AUDIO: "audio",
	SettingSection.MODE: "mode",
}

enum AudioSetting {
	MASTER_VOLUME,
	FADE_IN_DURATION,
	FADE_OUT_DURATION,
}

const AUDIO_SETTING_NAMES: Dictionary[AudioSetting, String] = {
	AudioSetting.MASTER_VOLUME: "master_volume",
	AudioSetting.FADE_IN_DURATION: "fade_in_duration",
	AudioSetting.FADE_OUT_DURATION: "fade_out_duration",
}

enum Mode {
	HOST,
	CLIENT,
	LOCAL,
}

const MODE_SETTING_NAME: String = "mode"

const SETTING_FILE_PATH: String = "user://settings.ini"
#endregion

var config = ConfigFile.new()

func _ready() -> void:
	if !FileAccess.file_exists(SETTING_FILE_PATH):
		
		config.set_value(SECTION_NAMES[SettingSection.AUDIO], AUDIO_SETTING_NAMES[AudioSetting.MASTER_VOLUME], 100.0)
		config.set_value(SECTION_NAMES[SettingSection.AUDIO], AUDIO_SETTING_NAMES[AudioSetting.FADE_IN_DURATION], 1.0)
		config.set_value(SECTION_NAMES[SettingSection.AUDIO], AUDIO_SETTING_NAMES[AudioSetting.FADE_OUT_DURATION], 1.0)
		config.set_value(SECTION_NAMES[SettingSection.MODE], MODE_SETTING_NAME, Mode.LOCAL)
		
		config.save(SETTING_FILE_PATH)
	else:
		config.load(SETTING_FILE_PATH)

func save_audio_setting(audio_setting: AudioSetting, value: Variant) -> Error:
	var section_name: String = SECTION_NAMES[SettingSection.AUDIO]
	var key_name: String = AUDIO_SETTING_NAMES[audio_setting]
	config.set_value(section_name, key_name, value)
	return config.save(SETTING_FILE_PATH)

func save_mode_setting(value: Mode) -> Error:
	config.set_value(SECTION_NAMES[SettingSection.MODE], MODE_SETTING_NAME, value)
	return config.save(SETTING_FILE_PATH)

func load_settings(section: SettingSection) -> Dictionary:
	var section_name: String = SECTION_NAMES.get(section)
	var settings := {}
	for key: String in config.get_section_keys(section_name):
		settings[key] = config.get_value(section_name, key)
	return settings

func load_audio_setting(section: SettingSection, audio_setting: AudioSetting) -> Variant:
	var section_name: String = SECTION_NAMES[section]
	var key_name: String = AUDIO_SETTING_NAMES[audio_setting]
	return config.get_value(section_name, key_name)

func load_mode_setting() -> Mode:
	var section_name: String = SECTION_NAMES[SettingSection.MODE]
	var key_name: String = MODE_SETTING_NAME
	return config.get_value(section_name, key_name)
