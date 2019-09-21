extends KinematicBody2D

class_name PlayerClass

const Speed := 65

var vel := Vector2(0, 0)

enum PlayerState { Move, NoInput }
enum Direction { Up, Down, Left, Right }

var state: int = PlayerState.Move
var face: int = Direction.Down
var walking := false

onready var spr: AnimatedSprite = $Sprite
onready var sight: Area2D = $Sight

# =====================================================================

func _physics_process(delta):
	set_z_index(int(get_position().y))
	
	match state:
		PlayerState.Move:
			var xx := int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
			var yy := int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
			
			vel.x = xx
			vel.y = yy
			
			walking = vel != Vector2.ZERO
			
			direction_management()
			sprite_management()
			
			move_and_slide(vel * Speed)

# =====================================================================

func get_state() -> int:
	return state


func set_state(value: int):
	state = value
	

func set_direction(value: int):
	face = value

# =====================================================================

func direction_management():
	if vel.x == 0:
		match vel.y:
			-1.0:
				face = Direction.Up
			1.0:
				face = Direction.Down
	elif vel.y == 0:
		match vel.x:
			-1.0:
				face = Direction.Left
			1.0:
				face = Direction.Right

	match face:
		Direction.Up:
			sight.set_rotation_degrees(180)
		Direction.Down:
			sight.set_rotation_degrees(0)
		Direction.Left:
			sight.set_rotation_degrees(90)
		Direction.Right:
			sight.set_rotation_degrees(270)
	

func sprite_management():
	match face:
		Direction.Up:
			spr.play("up_walk" if walking else "up")
		Direction.Down:
			spr.play("down_walk" if walking else "down")
		Direction.Left:
			spr.play("left_walk" if walking else "left")
		Direction.Right:
			spr.play("right_walk" if walking else "right")
