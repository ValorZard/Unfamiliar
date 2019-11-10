extends Node2D

onready var anim_player := $AnimationPlayer as AnimationPlayer

var active := false

func _process(delta):
	if Input.is_action_just_pressed("sys_menu") and active:
		anim_player.play("Disappear")


func _on_Button_clicked():
	print("BUTTON 1")


func _on_Button2_clicked():
	print("BUTTON 2")


func _on_Button3_clicked():
	print("BUTTON 3")


func _on_AnimationPlayer_animation_finished(anim_name: String):
	if anim_name == "Appear":
		active = true
	elif anim_name == "Disappear":
		Controller.set_menu_open(false)
		Player.set_state(Player.PlayerState.Move)
		queue_free()
