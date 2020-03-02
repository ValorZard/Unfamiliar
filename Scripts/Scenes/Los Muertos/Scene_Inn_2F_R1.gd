extends Node2D

export(NodePath) var door: NodePath

func _ready():
	if Controller.flag("story_day1_discourses_finished") == 0:
		get_node(door).queue_free()
