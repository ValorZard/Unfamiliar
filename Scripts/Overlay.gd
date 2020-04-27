extends Node2D

export(bool) var is_preview := false
export(AudioStream) var scene_music: AudioStream = null

func _ready():	
	if Controller.get_current_music() != scene_music:
		if scene_music != null:
			Controller.play_music(scene_music)
		else:
			Controller.fade_music(1)
	
	$CanvasLayer/Money.set_text(str(Controller.get_money()))
	if is_preview:
		queue_free()
