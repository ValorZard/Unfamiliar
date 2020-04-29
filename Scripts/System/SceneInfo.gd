extends Node

export(AudioStream) var scene_music: AudioStream = null
export(AudioStream) var scene_ambient: AudioStream = null
export(bool) var suppress_music := false
export(bool) var suppress_ambient := false


func _ready():
	if not suppress_music and Controller.get_current_music() != scene_music:
		if scene_music != null:
			Controller.fade_music(1.0)
			yield(Controller.wait(1.0), "timeout")
			Controller.play_music(scene_music)
		else:
			Controller.fade_music(1.0)

	if not suppress_ambient and Controller.get_current_ambient() != scene_ambient:
		if scene_ambient != null:
			Controller.fade_ambient(1.0)
			yield(Controller.wait(1.0), "timeout")
			Controller.play_ambient(scene_ambient)
		else:
			Controller.fade_ambient(1.0)
			
