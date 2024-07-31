extends Node2D

@export var mute: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func play_sfx(sound: AudioStream, parent: Node, volume: float = 0.0, seek: float = 0.0):
	if sound != null and parent != null:
		var stream = AudioStreamPlayer.new()
		
		stream.stream = sound
		stream.connect("finished", Callable(stream, "queue_free"))
		#stream.seek = seek
		stream.volume_db = volume
		
		parent.add_child(stream)
		
		stream.play()
		
