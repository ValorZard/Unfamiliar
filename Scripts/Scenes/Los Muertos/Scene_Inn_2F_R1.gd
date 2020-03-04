extends Node2D

export(NodePath) var door: NodePath
export(NodePath) var parts_1: NodePath
export(NodePath) var parts_2: NodePath

func _ready():
	if Controller.flag("story_day1_discourses_finished") == 0:
		get_node(door).queue_free()
		
	if Controller.flag("scn_inn_crisis") == 1:
		get_node(parts_1).set_emitting(true)
		get_node(parts_2).set_emitting(true)
