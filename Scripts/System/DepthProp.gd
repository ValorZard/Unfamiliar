tool
extends StaticBody2D

export(int) var height_add

func _process(delta):
	if Engine.editor_hint:
		set_z_index(get_position().y + height_add)
	else:
		set_process(false)
