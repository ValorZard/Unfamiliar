extends Node2D

var nav_pos: int = -1

onready var but1 := get_node("Button1")
onready var but2 := get_node("Button2")
onready var but3 := get_node("Button3")

onready var buttons = [but1, but2, but3]

onready var anim_player_blink := $Cosmo/AnimationPlayer

func _ready():
	Controller.draw_overlay(false)
	Player.hide()
	
	
func _process(delta):
	if Input.is_action_just_pressed("sys_up"):
		if nav_pos != -1:
			buttons[nav_pos]._on_areaHover_mouse_exited()
			nav_pos = wrapi(nav_pos - 1, 0, 3)
		else:
			nav_pos = 0
		buttons[nav_pos]._on_AreaHover_mouse_entered()
	
	if Input.is_action_just_pressed("sys_down"):
		if nav_pos != -1:
			buttons[nav_pos]._on_areaHover_mouse_exited()
			nav_pos = wrapi(nav_pos + 1, 0, 3)
		else:
			nav_pos = 0
		buttons[nav_pos]._on_AreaHover_mouse_entered()

# =====================================================================

func randomize_anim_player_speed():
	anim_player_blink.set_speed_scale(rand_range(0.25, 0.5))
	
	
func reset_anim_player_speed():
	anim_player_blink.set_speed_scale(1.2)

# =====================================================================

func _on_Button1_clicked() -> void:
	but1.anim_selected()
	but2.anim_not_selected()
	but3.anim_not_selected()
	yield(get_tree().create_timer(0.5), "timeout")
	$AnimationPlayerSetup.play("Teardown Start")
	yield($AnimationPlayerSetup, "animation_finished")
	Controller.draw_overlay(true)
	get_tree().change_scene("res://Scenes/Intro/Train1.tscn")


func _on_Button2_clicked() -> void:
	print("BUTTON 2")


func _on_Button3_clicked() -> void:
	but1.anim_not_selected()
	but2.anim_not_selected()
	but3.anim_selected()
	yield(get_tree().create_timer(0.5), "timeout")
	$AnimationPlayerSetup.play("Teardown")
	yield($AnimationPlayerSetup, "animation_finished")
	get_tree().quit()
