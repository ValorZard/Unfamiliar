extends Node2D

func _ready():
	if Controller.flag("scn_intro") == 1:
		get_node("CanvasLayer").queue_free()
		get_node("PlayerStart").queue_free()
		get_node("AnimationPlayer").stop()
		get_node("AnimationPlayer").seek(0)
		get_node("Bg").position.x += 80
		(get_node("Tutorial1") as ButtonUF).appear(true)
		(get_node("Tutorial1") as ButtonUF).set_modulate(Color(1, 1, 1, 1))
		(get_node("Tutorial2") as ButtonUF).appear(true)
		(get_node("Tutorial2") as ButtonUF).set_modulate(Color(1, 1, 1, 1))
		(get_node("Tutorial3") as ButtonUF).appear(true)
		(get_node("Tutorial3") as ButtonUF).set_modulate(Color(1, 1, 1, 1))
