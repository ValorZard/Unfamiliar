extends Node2D

func play_transition_sound():
	Controller.play_sound_oneshot($SoundTransition.get_stream(), 1, -3)
