extends Node2D

signal menu_closed

onready var button_settings := $CanvasLayerMisc/ButtonSettings as ButtonUF
onready var button_controls := $CanvasLayerMisc/ButtonControls as ButtonUF

onready var button_volume_1 := $CanvasLayerSettings/ButtonVolume1 as ButtonUF
onready var button_volume_2 := $CanvasLayerSettings/ButtonVolume2 as ButtonUF
onready var button_volume_3 := $CanvasLayerSettings/ButtonVolume3 as ButtonUF
onready var button_volume_4 := $CanvasLayerSettings/ButtonVolume4 as ButtonUF
onready var button_volume_5 := $CanvasLayerSettings/ButtonVolume5 as ButtonUF
onready var button_volume_6 := $CanvasLayerSettings/ButtonVolume6 as ButtonUF
onready var button_volume_7 := $CanvasLayerSettings/ButtonVolume7 as ButtonUF
onready var button_volume_8 := $CanvasLayerSettings/ButtonVolume8 as ButtonUF
onready var button_volume_9 := $CanvasLayerSettings/ButtonVolume9 as ButtonUF
onready var button_volume_10 := $CanvasLayerSettings/ButtonVolume10 as ButtonUF

onready var button_windowsize_1 := $CanvasLayerSettings/ButtonWindowSize1 as ButtonUF
onready var button_windowsize_2 := $CanvasLayerSettings/ButtonWindowSize2 as ButtonUF
onready var button_windowsize_3 := $CanvasLayerSettings/ButtonWindowSize3 as ButtonUF

onready var button_fullscreen_1 := $CanvasLayerSettings/ButtonFullscreen1 as ButtonUF
onready var button_fullscreen_2 := $CanvasLayerSettings/ButtonFullscreen2 as ButtonUF

onready var button_speed_1 := $CanvasLayerSettings/ButtonSpeed1 as ButtonUF
onready var button_speed_2 := $CanvasLayerSettings/ButtonSpeed2 as ButtonUF
onready var button_speed_3 := $CanvasLayerSettings/ButtonSpeed3 as ButtonUF
onready var button_speed_4 := $CanvasLayerSettings/ButtonSpeed4 as ButtonUF
onready var button_speed_5 := $CanvasLayerSettings/ButtonSpeed5 as ButtonUF
onready var button_speed_6 := $CanvasLayerSettings/ButtonSpeed6 as ButtonUF

onready var button_back := $CanvasLayerMisc/ButtonBack as ButtonUF

onready var buttons: Array = [button_settings, button_controls,
								button_volume_1, button_volume_2, button_volume_3, button_volume_4, button_volume_5, button_volume_6, button_volume_7, 
								button_volume_8, button_volume_9, button_volume_10, button_windowsize_1, button_windowsize_2, button_windowsize_3,
								button_fullscreen_1, button_fullscreen_2, button_speed_1, button_speed_2, button_speed_3, button_speed_4,
								button_speed_5, button_speed_6, button_back]


func _ready():
	yield(get_tree().create_timer(0.8), "timeout")
	for but in buttons:
		but.appear()


func _on_ButtonBack_clicked():
	Controller.select_menu_button(buttons, button_back.get_name())
