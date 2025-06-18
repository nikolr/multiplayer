class_name Track extends Resource

@export var stream: AudioStreamMP3
@export var filename: String
@export var path: String

static func create(path: String) -> Track:
	var track: Track = Track.new()
	track.stream = AudioStreamMP3.load_from_file(path)
	track.filename = path.get_file().get_basename()
	track.path = path
	# Forget the plugins and just write your own title extraction logic here
	return track

func _to_string() -> String:
	return filename
