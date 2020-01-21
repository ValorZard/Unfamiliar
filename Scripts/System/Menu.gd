extends Node2D

class_name Menu

var active := false

onready var but1 := $CanvasLayer/Button1 as ButtonUF
onready var but2 := $CanvasLayer/Button2 as ButtonUF
onready var but3 := $CanvasLayer/Button3 as ButtonUF
onready var but4 := $CanvasLayer/Button4 as ButtonUF

onready var buttons: Array = [but1, but2, but3, but4]

onready var anim_player := $AnimationPlayer as AnimationPlayer

# =====================================================================

func _process(delta):
	if Input.is_action_just_pressed("sys_menu") and active:
		anim_player.play("Disappear")
		
# =====================================================================

func _on_Button_clicked():
	Controller.select_menu_button(buttons, but1.get_name(), false)
	yield(Controller.wait(0.5), "timeout")
	yield(Controller.open_save_menu(false), "menu_closed")
	but1.set_clicked(false)
	but1.set_hover(false)
	for but in buttons:
		but.appear()


func _on_Button2_clicked():
	Controller.select_menu_button(buttons, but2.get_name(), false)
	yield(Controller.wait(0.5), "timeout")
	yield(Controller.open_options_menu(true), "menu_closed")
	but2.set_clicked(false)
	but2.set_hover(false)
	for but in buttons:
		but.appear()
	

func _on_Button3_clicked():
	Controller.select_menu_button(buttons, but3.get_name(), false)
	yield(Controller.wait(0.5), "timeout")
	yield(Controller.open_exit_menu(self), "menu_closed")
	but3.set_clicked(false)
	but3.set_hover(false)
	for but in buttons:
		but.appear()
		
		
func _on_Button4_clicked():
	Controller.select_menu_button(buttons, but4.get_name(), true)
	anim_player.play("Disappear 2")
	

func _on_AnimationPlayer_animation_finished(anim_name: String):
	if anim_name == "Appear":
		active = true
	elif anim_name == "Disappear" or anim_name == "Disappear 2":
		Controller.set_menu_open(false)
		Player.set_state(Player.PlayerState.Move)
		queue_free()
