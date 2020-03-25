extends Node2D

onready var sound_telephone := $SoundTelephone as AudioStreamPlayer

func stop_telephone():
	(sound_telephone.get_stream() as AudioStreamOGGVorbis).set_loop(false)
