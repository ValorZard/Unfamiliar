extends Node2D

export(bool) var is_preview := false

func _ready():	
	$CanvasLayer/Money.set_text(str(Controller.get_money()))
	if is_preview:
		queue_free()
