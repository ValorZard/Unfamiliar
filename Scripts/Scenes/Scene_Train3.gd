extends Node2D

export(NodePath) var npc_rhona: NodePath

func _ready():
	if Controller.flag("scn_rhona") == 1:
		get_node(npc_rhona).queue_free()
