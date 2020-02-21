extends Node2D

export(NodePath) var clive_npc

func _ready():
	if Controller.flag("story_day1_d_ariad_1") == 0:
		get_node(clive_npc).queue_free()
