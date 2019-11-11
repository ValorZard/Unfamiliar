extends Node2D

var nav_pos: int = -1
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
	
	but1.connect("hover_start", self, "_on_Button1_hover_start")
	but2.connect("hover_start", self, "_on_Button2_hover_start")
	but3.connect("hover_start", self, "_on_Button3_hover_start")
	but4.connect("hover_start", self, "_on_Button4_hover_start")
	
	
func _process(delta):
	if active:
		if Input.is_action_just_pressed("sys_up"):
			if nav_pos != -1:
				buttons[nav_pos]._on_AreaHover_mouse_exited()
				nav_pos = wrapi(nav_pos - 1, 0, 4)
			else:
				nav_pos = 0
			buttons[nav_pos]._on_AreaHover_mouse_entered()
		
		if Input.is_action_just_pressed("sys_down"):
			if nav_pos != -1:
				buttons[nav_pos]._on_AreaHover_mouse_exited()
				nav_pos = wrapi(nav_pos + 1, 0, 4)
			else:
				nav_pos = 0
			buttons[nav_pos]._on_AreaHover_mouse_entered()

# =====================================================================

func set_active():
	active = true


func randomize_anim_player_speed():
	anim_player_blink.set_speed_scale(rand_range(0.25, 0.5))
	
	
func reset_anim_player_speed():
	anim_player_blink.set_speed_scale(1.2)

# =====================================================================

func _on_Button1_hover_start() -> void:
	but2._on_AreaHover_mouse_exited()
	but3._on_AreaHover_mouse_exited()
	but4._on_AreaHover_mouse_exited()
	nav_pos = 0
	

func _on_Button2_hover_start() -> void:
	but1._on_AreaHover_mouse_exited()
	but3._on_AreaHover_mouse_exited()
	but4._on_AreaHover_mouse_exited()
	nav_pos = 1
	
	
func _on_Button3_hover_start() -> void:
	but1._on_AreaHover_mouse_exited()
	but2._on_AreaHover_mouse_exited()
	but4._on_AreaHover_mouse_exited()
	nav_pos = 2


func _on_Button4_hover_start():
	but1._on_AreaHover_mouse_exited()
	but2._on_AreaHover_mouse_exited()
	but3._on_AreaHover_mouse_exited()
	nav_pos = 3


func _on_Button1_clicked() -> void:
	active = false
	but1.anim_selected(false)
	but2.anim_not_selected(false)
	but3.anim_not_selected(false)
	but4.anim_not_selected(false)
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
	but1.anim_not_selected(false)
	but2.anim_selected(false)
	but3.anim_not_selected(false)
	but4.anim_not_selected(false)
	yield(get_tree().create_timer(0.5), "timeout")
	$AnimationPlayerSetup.play("Teardown Options 2")
	yield($AnimationPlayerSetup, "animation_finished")
	yield(Controller.open_save_menu(true, false), "menu_closed")
	but2.set_clicked(false)
	but2.set_hover(false)
	$AnimationPlayerSetup.play("Unteardown")


func _on_Button3_clicked() -> void:
	active = false
	but1.anim_not_selected(false)
	but2.anim_not_selected(false)
	but3.anim_selected(false)
	but4.anim_not_selected(false)
	yield(get_tree().create_timer(0.5), "timeout")
	$AnimationPlayerSetup.play("Teardown Options 2")
	yield($AnimationPlayerSetup, "animation_finished")


func _on_Button4_clicked() -> void:
	active = false
	but1.anim_not_selected(false)
	but2.anim_not_selected(false)
	but3.anim_not_selected(false)
	but4.anim_selected(false)
	yield(get_tree().create_timer(0.5), "timeout")
	$AnimationPlayerSetup.play("Teardown")
	yield($AnimationPlayerSetup, "animation_finished")
	get_tree().quit()
