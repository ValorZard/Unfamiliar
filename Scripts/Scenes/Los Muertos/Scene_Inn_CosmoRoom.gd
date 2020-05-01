extends Node2D

var can_quit := false

onready var anim_player := $AnimationPlayer as AnimationPlayer

func _process(delta):
	Player.set_state(Player.PlayerState.NoInput)
	
	if can_quit and Input.is_action_just_pressed("sys_action"):
		anim_player.play("End")
		
		
func set_can_quit():
	can_quit = true
	

func _on_MusicEnding_finished():
	anim_player.play("End")


func _on_AnimationPlayer_animation_finished(anim_name):
	Controller.goto_scene("res://Scenes/Title/Title.tscn", Vector2.ZERO, 0, false)
	Controller.draw_overlay(false)
	Controller.draw_overlay_map(false)
	Player.hide()
	Controller.fade(1, false, Color(0, 0, 0), true)
	Controller.set_menu_open(false)
	
