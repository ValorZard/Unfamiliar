extends Node2D

export(NodePath) var npc_ravia: NodePath
export(NodePath) var npc_pascal: NodePath

onready var sound_telephone := $SoundTelephone as AudioStreamPlayer

func _ready():
	if Controller.flag("scn_fletcher") == 1:
		var ravia := get_node(npc_ravia) as EventNPC
		ravia.set_position(Vector2(182, 76))
		ravia.set_sprite_override(false)
		ravia.set_direction(2)
		var pascal := get_node(npc_pascal) as EventNPC
		pascal.set_position(Vector2(196, 46))
		pascal.hide()


func stop_telephone():
	(sound_telephone.get_stream() as AudioStreamOGGVorbis).set_loop(false)
