extends Node2D

export(PoolStringArray) var item_names
export(PoolStringArray) var item_descs

var hover: int = -1

onready var text_name := $CanvasLayer/ItemName
onready var text_desc := $CanvasLayer/ItemDesc

# =====================================================================

func _process(delta):
	text_name.set_text(item_names[hover] if hover != -1 else "")
	text_desc.set_text(item_descs[hover] if hover != -1 else "")

# =====================================================================

func set_hover_index(value: int):
	hover = value
