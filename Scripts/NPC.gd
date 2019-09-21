extends KinematicBody2D

enum NPCDirection { Up, Down, Left, Right }

export(String, FILE, "*.txt") var dialogue_file
export(NPCDirection) var start_direction = NPCDirection.Down

var face: int = NPCDirection.Down

var in_range := false

onready var spr: AnimatedSprite = $Sprite
onready var interact: Sprite = $Interact

# =====================================================================

func _ready():
	interact.hide()
	face = start_direction
	
func _process(delta):
	set_z_index(int(get_position().y))
	
	_sprite_management()
	
	if Input.is_action_just_pressed("sys_select") and in_range and Player.get_state() == Player.PlayerState.Move:
		interact.hide()
		_face_player()
		yield(Controller.dialogue(dialogue_file), "dialogue_ended")
		interact.show()
		
# =====================================================================

func _face_player():
	match Player.get_direction():
		Player.Direction.Up:
			face = NPCDirection.Down
		Player.Direction.Down:
			face = NPCDirection.Up
		Player.Direction.Left:
			face = NPCDirection.Right
		Player.Direction.Right:
			face = NPCDirection.Left
			

func _sprite_management():
	match face:
		NPCDirection.Up:
			spr.play("up")
		NPCDirection.Down:
			spr.play("down")
		NPCDirection.Left:
			spr.play("left")
		NPCDirection.Right:
			spr.play("right")
	
# =====================================================================

func _on_InteractArea_area_entered(area: Area2D):
	if area.is_in_group("PlayerSight"):
		in_range = true
		interact.show()


func _on_InteractArea_area_exited(area: Area2D):
	if area.is_in_group("PlayerSight"):
		in_range = false
		interact.hide()
