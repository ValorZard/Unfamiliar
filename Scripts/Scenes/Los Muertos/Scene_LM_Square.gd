extends Node2D

export(NodePath) var clive_npc
export(NodePath) var ariad_npc

func _ready():
	if Controller.flag("story_day1_d_ariad_1") == 0:
		get_node(clive_npc).queue_free()
	
	if Controller.flag("story_day1_d_ariad_2") == 1:
		get_node(clive_npc).queue_free()
		get_node(ariad_npc).queue_free()
