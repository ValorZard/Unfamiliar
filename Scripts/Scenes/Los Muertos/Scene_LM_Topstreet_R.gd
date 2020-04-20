extends Node2D

export(NodePath) var arcade_sign_player: NodePath

func _ready():
	if Controller.flag("story_day1_discourses_finished") == 1:
		(get_node(arcade_sign_player) as AnimationPlayer).play("Idle2")
