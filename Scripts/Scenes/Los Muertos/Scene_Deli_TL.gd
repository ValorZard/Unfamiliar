extends Node2D

export(NodePath) var npc_yaga1: NodePath
export(NodePath) var npc_yaga2: NodePath
export(NodePath) var npc_imp: NodePath
export(NodePath) var plate: NodePath

func _ready():
	if Controller.flag("scn_deli_yaga") == 1:
		(get_node(npc_yaga1) as EventNPC).hide()
		var yaga := get_node(npc_yaga2) as EventNPC
		yaga.set_position(Vector2(134, 66))
		yaga.set_direction(2)
		yaga.show()
		var imp := get_node(npc_imp) as NPC
		imp.set_dialogue_set(2)
		Controller.set_flag("npc_deli_imp1", 2)
		(get_node(plate) as Sprite).show()
		Player.set_sprite_override(false)
		
	if Controller.flag("scn_deli_yaga") >= 1:
		(get_node(npc_imp) as NPC).set_set_limit(3)
