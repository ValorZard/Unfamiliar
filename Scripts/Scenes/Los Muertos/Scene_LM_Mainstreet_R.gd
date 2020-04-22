extends Node2D

export(NodePath) var keifer: NodePath

func _ready():
	if Controller.flag("scn_lm_keifer") == 1:
		(get_node(keifer) as EventNPC).set_sprite_override(false)
