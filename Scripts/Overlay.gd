extends Node2D

export(bool) var is_preview := false

func _ready():
	if is_preview:
		queue_free()
