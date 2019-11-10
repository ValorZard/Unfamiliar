extends Node2D

var active := false

onready var but1 := $CanvasLayer/Button1 as ButtonUF
onready var but2 := $CanvasLayer/Button2 as ButtonUF
onready var but3 := $CanvasLayer/Button3 as ButtonUF

onready var anim_player := $AnimationPlayer as AnimationPlayer

# =====================================================================

func _process(delta):
	if Input.is_action_just_pressed("sys_menu") and active:
		anim_player.play("Disappear")
		
# =====================================================================

func _on_Button_clicked():
	but1.anim_selected(false)
	but2.anim_not_selected(false)
	but3.anim_not_selected(false)


func _on_Button2_clicked():
	but1.anim_not_selected(false)
	but2.anim_selected(false)
	but3.anim_not_selected(false)


func _on_Button3_clicked():
	but1.anim_not_selected(false)
	but2.anim_not_selected(false)
	but3.anim_selected(false)


func _on_AnimationPlayer_animation_finished(anim_name: String):
	if anim_name == "Appear":
		active = true
	elif anim_name == "Disappear":
		Controller.set_menu_open(false)
		Player.set_state(Player.PlayerState.Move)
		queue_free()
