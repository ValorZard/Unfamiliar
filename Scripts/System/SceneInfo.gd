extends Node

export(AudioStream) var scene_music: AudioStream = null
export(AudioStream) var scene_ambient: AudioStream = null
export(bool) var suppress_music := false
export(bool) var suppress_ambient := false

onready var timer_music := $TimerMusic as Timer
onready var timer_music2 := $TimerMusic2 as Timer
onready var timer_ambient := $TimerAmbient as Timer
onready var timer_ambient2 := $TimerAmbient2 as Timer


func _ready():
	if not suppress_music and not Controller.is_mid_event() and Controller.get_current_music() != scene_music:
		if scene_music != null:
			if Controller.get_current_music() != null:
				Controller.fade_music(1.0)
				timer_music.start()
			else:
				Controller.play_music(scene_music)
		else:
			Controller.fade_music(1.0)
			timer_music2.start()

	if not suppress_ambient and Controller.get_current_ambient() != scene_ambient:
		if scene_ambient != null:
			Controller.fade_ambient(1.0)
			timer_ambient.start()
		else:
			Controller.fade_ambient(1.0)
			timer_ambient2.start()
			
			
func timer_music_play():
	Controller.play_music(scene_music)
	
func timer_music_stop():
	Controller.stop_music()
	
func timer_ambient_play():
	Controller.play_ambient(scene_ambient, 1.0, 0.0, true)
	
func timer_ambient_stop():
	Controller.stop_ambient()
