extends KinematicBody2D

class_name EventNPC

enum NPCDirection { Up, Down, Left, Right }

export(NPCDirection) var start_direction = NPCDirection.Down
export(bool) var change_direction = true
export(bool) var auto_advance_set = false
export(int) var set_limit = 0
export(String) var set_flag

var face: int = NPCDirection.Down

var in_range := false
var can_talk_to := true

var dialogue_set: int = 0

var sprite_override := false

onready var spr: AnimatedSprite = $Sprite
onready var interact: Sprite = $Interact
onready var event: Event = $Event

# =====================================================================

func _ready():
	interact.hide()
	face = start_direction
	dialogue_set = Controller.flag(set_flag)
	
	
func _process(delta):
	set_z_index(int(get_position().y))
	
	if not sprite_override:
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
		Controller.set_flag(set_flag, dialogue_set)
		interact.show()
		
# =====================================================================

func set_sprite_override(value: bool):
	sprite_override = value
	

func increment_dialogue_set():
	dialogue_set += 1
	Controller.set_flag(set_flag, dialogue_set)
	
	
func show_interact(show: bool):
	interact.set_visible(show)
	

func set_can_talk_to(value: bool):
	can_talk_to = value

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
	if can_talk_to and area.is_in_group("PlayerSight"):
		in_range = true
		interact.show()


func _on_InteractArea_area_exited(area: Area2D):
	if area.is_in_group("PlayerSight"):
		in_range = false
		interact.hide()
