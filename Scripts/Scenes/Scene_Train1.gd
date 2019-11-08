extends Node2D

func _ready():
	if Controller.flag("scn_intro") == 1:
		get_node("CanvasLayer").queue_free()
		get_node("PlayerStart").queue_free()
		get_node("AnimationPlayer").stop()
		get_node("AnimationPlayer").seek(0)
		get_node("Bg").position.x += 80
