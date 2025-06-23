class_name Track extends Resource

@export var stream: AudioStream
@export var filename: String
@export var path: String
@export var volume: float = 1.0

static func create(path: String) -> Track:
	var track: Track = Track.new()
	var extension: String = path.get_extension()
	match extension:
		"mp3":
			track.stream = AudioStreamMP3.load_from_file(path)
		"wav":
			track.stream = AudioStreamWAV.load_from_file(path)
	track.filename = path.get_file().get_basename()
	track.path = path
	return track

func _to_string() -> String:
	return filename
