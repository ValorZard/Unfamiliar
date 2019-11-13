extends Node2D

var active := false

onready var but1 := $Button1 as ButtonUF
onready var but2 := $Button2 as ButtonUF
onready var but3 := $Button3 as ButtonUF
onready var but4 := $Button4 as ButtonUF

onready var buttons = [but1, but2, but3, but4]

onready var anim_player_blink := $Cosmo/AnimationPlayer as AnimationPlayer

# =====================================================================

func _ready():
	Controller.draw_overlay(false)
	Controller.draw_overlay_map(false)
	Player.hide()

# =====================================================================

func set_active():
	active = true


func randomize_anim_player_speed():
	anim_player_blink.set_speed_scale(rand_range(0.25, 0.5))
	
	
func reset_anim_player_speed():
	anim_player_blink.set_speed_scale(1.2)

# =====================================================================

func _on_Button1_clicked() -> void:
	active = false
	Controller.select_menu_button(buttons, but1.get_name())
	yield(get_tree().create_timer(0.5), "timeout")
	$AnimationPlayerSetup.play("Teardown Start")
	yield($AnimationPlayerSetup, "animation_finished")
	Controller.draw_overlay(true)
	Controller.draw_overlay_map(true)
	get_tree().change_scene("res://Scenes/Intro/Train1.tscn")
	Controller.set_playtime(0)
	Controller.set_tracking_playtime(true)
	#get_tree().change_scene("res://Scenes/Intro/IntroNew.tscn")


func _on_Button2_clicked() -> void:
	active = false
	Controller.select_menu_button(buttons, but2.get_name(), false)
	yield(get_tree().create_timer(0.5), "timeout")
	$AnimationPlayerSetup.play("Teardown Options 2")
	yield($AnimationPlayerSetup, "animation_finished")
	yield(Controller.open_save_menu(true, false), "menu_closed")
	but2.set_clicked(false)
	but2.set_hover(false)
	$AnimationPlayerSetup.play("Unteardown")


func _on_Button3_clicked() -> void:
	active = false
	Controller.select_menu_button(buttons, but3.get_name(), false)
	yield(get_tree().create_timer(0.5), "timeout")
	$AnimationPlayerSetup.play("Teardown Options 2")
	yield($AnimationPlayerSetup, "animation_finished")
	yield(Controller.open_options_menu(false), "menu_closed")
	but3.set_clicked(false)
	but3.set_hover(false)
	$AnimationPlayerSetup.play("Unteardown")


func _on_Button4_clicked() -> void:
	active = false
	Controller.select_menu_button(buttons, but4.get_name())
	yield(get_tree().create_timer(0.5), "timeout")
	$AnimationPlayerSetup.play("Teardown")
	yield($AnimationPlayerSetup, "animation_finished")
	get_tree().quit()
