extends Node2D

export(bool) var skip_logos := false

func _ready():
	Controller.draw_overlay(false)
	Controller.draw_overlay_map(false)
	Player.hide()
	Player.set_state(Player.PlayerState.NoInput)
	
	if skip_logos:
		get_tree().change_scene("res://Scenes/Title/Title.tscn")
	else:
		yield(Controller.wait(1.0), "timeout")
		get_tree().change_scene("res://Scenes/Title/Logos.tscn")
