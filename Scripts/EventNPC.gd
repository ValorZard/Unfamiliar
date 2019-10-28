extends KinematicBody2D

class_name EventNPC

enum NPCDirection { Up, Down, Left, Right }

export(NPCDirection) var start_direction = NPCDirection.Down
export(bool) var change_direction = true
export(bool) var auto_advance_set = false
export(int) var set_limit = 0

var face: int = NPCDirection.Down

var in_range := false

var dialogue_set: int = 0

onready var spr: AnimatedSprite = $Sprite
onready var interact: Sprite = $Interact
onready var event: Event = $Event

# =====================================================================

func _ready():
	interact.hide()
	face = start_direction
	
func _process(delta):
	set_z_index(int(get_position().y))
	
	_sprite_management()
	
	if Input.is_action_just_pressed("sys_action") and in_range and Player.get_state() == Player.PlayerState.Move:
		interact.hide()
		if change_direction:
			_face_player()
		
		Controller.set_previous_npc(get_path())
		event.start_event(dialogue_set)
		yield(event, "event_ended")
		if auto_advance_set and dialogue_set < set_limit:
			dialogue_set += 1
		interact.show()
		
# =====================================================================

func increment_dialogue_set():
	dialogue_set += 1
	
	
func show_interact(show: bool):
	interact.set_visible(show)

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
