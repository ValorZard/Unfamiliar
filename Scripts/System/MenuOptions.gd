extends Node2D

signal menu_closed

# warning-ignore:unused_class_variable
onready var button_volume_1 := $CanvasLayerSettings/ButtonVolume1 as ButtonUF
# warning-ignore:unused_class_variable
onready var button_volume_2 := $CanvasLayerSettings/ButtonVolume2 as ButtonUF
# warning-ignore:unused_class_variable
onready var button_volume_3 := $CanvasLayerSettings/ButtonVolume3 as ButtonUF
# warning-ignore:unused_class_variable
onready var button_volume_4 := $CanvasLayerSettings/ButtonVolume4 as ButtonUF
# warning-ignore:unused_class_variable
onready var button_volume_5 := $CanvasLayerSettings/ButtonVolume5 as ButtonUF
# warning-ignore:unused_class_variable
onready var button_volume_6 := $CanvasLayerSettings/ButtonVolume6 as ButtonUF
# warning-ignore:unused_class_variable
onready var button_volume_7 := $CanvasLayerSettings/ButtonVolume7 as ButtonUF
# warning-ignore:unused_class_variable
onready var button_volume_8 := $CanvasLayerSettings/ButtonVolume8 as ButtonUF
# warning-ignore:unused_class_variable
onready var button_volume_9 := $CanvasLayerSettings/ButtonVolume9 as ButtonUF
# warning-ignore:unused_class_variable
onready var button_volume_10 := $CanvasLayerSettings/ButtonVolume10 as ButtonUF

# warning-ignore:unused_class_variable
onready var button_windowsize_1 := $CanvasLayerSettings/ButtonWindowSize1 as ButtonUF
# warning-ignore:unused_class_variable
onready var button_windowsize_2 := $CanvasLayerSettings/ButtonWindowSize2 as ButtonUF
# warning-ignore:unused_class_variable
onready var button_windowsize_3 := $CanvasLayerSettings/ButtonWindowSize3 as ButtonUF

# warning-ignore:unused_class_variable
onready var button_fullscreen_1 := $CanvasLayerSettings/ButtonFullscreen1 as ButtonUF
# warning-ignore:unused_class_variable
onready var button_fullscreen_2 := $CanvasLayerSettings/ButtonFullscreen2 as ButtonUF

# warning-ignore:unused_class_variable
onready var button_speed_1 := $CanvasLayerSettings/ButtonSpeed1 as ButtonUF
# warning-ignore:unused_class_variable
onready var button_speed_2 := $CanvasLayerSettings/ButtonSpeed2 as ButtonUF
# warning-ignore:unused_class_variable
onready var button_speed_3 := $CanvasLayerSettings/ButtonSpeed3 as ButtonUF
# warning-ignore:unused_class_variable
onready var button_speed_4 := $CanvasLayerSettings/ButtonSpeed4 as ButtonUF
# warning-ignore:unused_class_variable
onready var button_speed_5 := $CanvasLayerSettings/ButtonSpeed5 as ButtonUF
# warning-ignore:unused_class_variable
onready var button_speed_6 := $CanvasLayerSettings/ButtonSpeed6 as ButtonUF

onready var button_back := $CanvasLayerMisc/ButtonBack as ButtonUF

onready var buttons: Array = [	button_volume_1, button_volume_2, button_volume_3, button_volume_4, button_volume_5, button_volume_6, button_volume_7, 
								button_volume_8, button_volume_9, button_volume_10, button_windowsize_1, button_windowsize_2, button_windowsize_3,
								button_fullscreen_1, button_fullscreen_2, button_speed_1, button_speed_2, button_speed_3, button_speed_4,
								button_speed_5, button_speed_6, button_back	]

var volume_value: int = 7
var windowsize_value: int = 0
var fullscreen_value: int = 0
var speed_ow_value: int = 1
var speed_d_value: int = 2

var active := false

# =====================================================================

func _ready():
	Controller.connect("fullscreen_toggled", self, "fullscreen_changed")
	yield(get_tree().create_timer(0.8), "timeout")
	
	load_settings()
	update_shading()
	
	for but in buttons:
		but.appear()
		
# =====================================================================

func start(use_background: bool):
	if not use_background:
		$CanvasLayerSettings/ColorRect.hide()
		
	$AnimationPlayer.play("Appear")
		
		
func set_volume(value: float):
	volume_value = int(value * 10)
	update_controller_settings()
	update_shading()
	save_settings()
		
		
func set_windowsize(value: int):
	windowsize_value = value
	update_controller_settings()
	update_shading()
	save_settings()
	
	
func set_fullscreen(value: int):
	fullscreen_value = value
	update_controller_settings()
	update_shading()
	save_settings()
	
	
func set_speed_ow(value: int):
	speed_ow_value = value
	update_controller_settings()
	update_shading()
	save_settings()
	
	
func set_speed_d(value: int):
	speed_d_value = value
	update_controller_settings()
	update_shading()
	save_settings()
		
		
func update_shading():
	# Volume
	for i in range(10):
		(buttons[i] as ButtonUF).set_shaded(i < volume_value)
	
	# Windowsize
	for i in range(3):
		(buttons[i + 10] as ButtonUF).set_shaded(i == windowsize_value)
		
	# Fullscreen
	for i in range(2):
		(buttons[i + 13] as ButtonUF).set_shaded(i != fullscreen_value)
		
	# Overworld speed
	for i in range(3):
		(buttons[i + 15] as ButtonUF).set_shaded(i == speed_ow_value)
		
	# Discourse speed
	for i in range(3):
		(buttons[i + 18] as ButtonUF).set_shaded(i == speed_d_value)
		
		
func update_controller_settings():
	Controller.update_settings(volume_value, windowsize_value, fullscreen_value, speed_ow_value, speed_d_value)
		
		
func save_settings():
	Controller.save_settings()
		
		
func load_settings():
	volume_value = int(Controller.settings["volume"])
	windowsize_value = int(Controller.settings["window_size"])
	fullscreen_value = bool(Controller.settings["fullscreen"])
	speed_ow_value = int(Controller.settings["text_speed_overworld"])
	speed_d_value = int(Controller.settings["text_speed_discourse"])
	
	
func fullscreen_changed(value: bool):
	fullscreen_value = value
	update_controller_settings()
	update_shading()


func _on_ButtonBack_clicked():
	Controller.select_menu_button(buttons, button_back.get_name())
	yield(get_tree().create_timer(0.6), "timeout")
	$AnimationPlayer.play("Disappear")
	
	
func _on_AnimationPlayer_animation_finished(anim_name: String):
	if anim_name == "Appear":
		active = true
	elif anim_name == "Disappear":
		emit_signal("menu_closed")
		queue_free()
