extends Node2D

export(NodePath) var clive_npc: NodePath
export(NodePath) var ariad_npc: NodePath

func _ready():
	if Controller.flag("scn_lm_ariad") == 1:
		(get_node(clive_npc) as EventNPC).show()
