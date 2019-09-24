extends Node2D

const PosX: int = 86
const PosY: int = 27

var pos: int = 0
var buffer := true

onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready():
	set_position(Vector2(PosX, PosY))
	yield(get_tree().create_timer(0.1), "timeout")
	buffer = false


func _process(delta):
	if Input.is_action_just_pressed("sys_up"):
		pos = wrapi(pos - 1, 0, 3)
	if Input.is_action_just_pressed("sys_down"):
		pos = wrapi(pos + 1, 0, 3)
	
	anim_player.set_current_animation("Option" + str(pos + 1))
	
	
	if Input.is_action_just_pressed("sys_menu") and not buffer:
		Player.set_state(Player.PlayerState.Move)
		Controller.set_menu_open(false)
		queue_free()
