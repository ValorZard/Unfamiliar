extends Node2D

func flashback():
	Controller.flashback("res://Flashbacks/fb_opening.txt", null, false, $AnimationPlayer as AnimationPlayer)
