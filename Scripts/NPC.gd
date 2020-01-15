extends KinematicBody2D

signal dialogue_finished

enum NPCDirection { Up, Down, Left, Right }

export(String, FILE, "*.txt") var dialogue_file
export(NPCDirection) var start_direction = NPCDirection.Down
export(bool) var change_direction = true
export(bool) var auto_advance_set = false
export(int) var set_start = 0
export(int) var set_limit = 0
export(String) var set_flag
export(bool) var auto_set_flag = true
export(bool) var is_object = false
export(bool) var alt_text_box = false

export(NPCDirection) var face := NPCDirection.Down

export(bool) var require_direction := false
export(int, "Up", "Down", "Left", "Right") var required_direction := 0

var in_range := false
var can_interact := false

var can_talk_to := true

var dialogue_set: int = 0

onready var spr: AnimatedSprite = $Sprite
onready var interact: Sprite = $Interact

# =====================================================================

func _ready():
	interact.hide()
	face = start_direction
	dialogue_set = set_start
	if auto_set_flag:
		dialogue_set = Controller.flag(set_flag)
		
	if require_direction:
		Player.connect("direction_changed", self, "_refresh_range_check")
	
func _process(delta):
	set_z_index(int(get_position().y))
	
	_sprite_management()
	
	if Input.is_action_just_pressed("sys_action") and in_range and can_interact and Player.get_state() == Player.PlayerState.Move:
		if is_object:
			Player.show_interact(false)
		else:
			interact.hide()
			
		if change_direction:
			_face_player()
		var d := Controller.dialogue(dialogue_file, dialogue_set, alt_text_box)
		yield(d, "dialogue_ended")
		if auto_advance_set and dialogue_set < set_limit:
			dialogue_set += 1
		if auto_set_flag:
			Controller.set_flag(set_flag, dialogue_set)
			
		if is_object:
			Player.show_interact(true)
		else:
			interact.show()
			
		emit_signal("dialogue_finished")
		
# =====================================================================

func set_can_talk_to(value: bool):
	can_talk_to = value
		
# =====================================================================

func _refresh_range_check(face: int):
	if in_range and require_direction and face == required_direction:
		can_interact = true
		if is_object:
			Player.show_interact(true)
		else:
			interact.show()
	else:
		can_interact = false
		if is_object:
			Player.show_interact(false)
		else:
			interact.hide()


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
	if can_talk_to and area.is_in_group("PlayerSight") and not Player.is_in_an_area():
		in_range = true
		Player.set_in_an_area(true)
		if not require_direction or (require_direction and Player.get_direction() == required_direction):
			can_interact = true
			if is_object:
				Player.show_interact(true)
			else:
				interact.show()


func _on_InteractArea_area_exited(area: Area2D):
	if area.is_in_group("PlayerSight"):
		in_range = false
		can_interact = false
		if Player.is_in_an_area():
			Player.set_in_an_area(false)
		if is_object:
			Player.show_interact(false)
		else:
			interact.hide()
