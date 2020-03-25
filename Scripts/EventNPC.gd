extends KinematicBody2D

class_name EventNPC

signal dialogue_finished

enum NPCDirection { Up, Down, Left, Right }

export(NPCDirection) var start_direction = NPCDirection.Down
export(bool) var change_direction := true
export(bool) var auto_advance_set := false
export(int) var set_limit := 0
export(String) var set_flag
export(bool) var auto_set_flag := true
export(bool) var is_object := false

var face: int = NPCDirection.Down

var vel_override := Vector2(0, 0)
var speed_override: float = 0.0
var walking := false

var in_range := false
var can_interact := false

export(bool) var can_talk_to := true

var dialogue_set: int = 0

export(bool) var sprite_override := false

export(bool) var require_direction := false
export(int, "Up", "Down", "Left", "Right") var required_direction := 0

export(Array, AudioStream) var step_sounds_conc

var idle_sprites: Array = ["up", "down", "left", "right"]
var walk_sprites: Array = ["up_walk", "down_walk", "left_walk", "right_walk"]

onready var spr: AnimatedSprite = $Sprite
onready var interact: Sprite = $Interact
onready var event: Event = $Event

# =====================================================================

func _ready():
	interact.hide()
	face = start_direction
	if auto_set_flag:
		dialogue_set = Controller.flag(set_flag)
		
	if require_direction:
		Player.connect("direction_changed", self, "_refresh_range_check")
	
	
func _process(delta):
	set_z_index(int(get_position().y))
	
	if not sprite_override:
		_sprite_management()
	
	if Input.is_action_just_pressed("sys_action") and in_range and can_interact and Player.get_state() == Player.PlayerState.Move:
		if is_object:
			Player.show_interact(false)
		else:
			interact.hide()
			
		if change_direction:
			_face_player()

		event.start_event(dialogue_set)
		yield(event, "event_ended")
		if auto_advance_set and dialogue_set < set_limit:
			dialogue_set += 1
		if auto_set_flag:
			Controller.set_flag(set_flag, dialogue_set)
		if is_object:
			Player.show_interact(true)
		else:
			interact.show()
			
		emit_signal("dialogue_finished")
		
		
func _physics_process(delta):
	if speed_override > 0 and not walking:
		_play_footstep_sound()
		
	walking = speed_override > 0
		
	if not sprite_override:
		_sprite_management()
		
	move_and_slide(vel_override * speed_override)
		
# =====================================================================

func set_direction(value: int):
	face = value


func set_sprite_override(value: bool):
	sprite_override = value
	
	
func set_vel_override(value: Vector2):
	vel_override = value
	
	
func set_speed_override(value: float):
	speed_override = value
	

func increment_dialogue_set():
	dialogue_set += 1
	Controller.set_flag(set_flag, dialogue_set)
	

func set_dialogue_set(value: int):
	dialogue_set = value
	
	
func show_interact(show: bool):
	interact.set_visible(show)
	

func set_can_talk_to(value: bool):
	can_talk_to = value
	
	
func replace_idle_animation(direction: int, anim: String):
	idle_sprites[direction] = anim


func replace_walk_animation(direction: int, anim: String):
	walk_sprites[direction] = anim

# =====================================================================

func _refresh_range_check(face_: int):
	if in_range and require_direction and face_ == required_direction:
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
#	var anim: String
#	match face:
#		NPCDirection.Up:
#			anim = "up"
#		NPCDirection.Down:
#			anim = "down"
#		NPCDirection.Left:
#			anim = "left"
#		NPCDirection.Right:
#			anim = "right"
#
#	if walking:
#		anim += "_walk"
#
#	spr.play(anim)
	var index := int(face)
	spr.play(walk_sprites[index] if walking else idle_sprites[index])
	
	
func _play_footstep_sound():
	Controller.play_sound_oneshot(step_sounds_conc[int(round(rand_range(0, len(step_sounds_conc) - 1)))], rand_range(0.95, 1.05), -4)
	
# =====================================================================

func _on_InteractArea_area_entered(area: Area2D):
	if can_talk_to and area.is_in_group("PlayerSight") and not Player.is_in_an_area() and Player.get_state() == Player.PlayerState.Move:
		in_range = true
		Player.set_in_an_area(true)
		if not require_direction or (require_direction and Player.get_direction() == required_direction):
			can_interact = true
			if is_object:
				Player.show_interact(true)
			else:
				interact.show()


func _on_InteractArea_area_exited(area: Area2D):
	if area.is_in_group("PlayerSight") and Player.get_state() == Player.PlayerState.Move:
		in_range = false
		can_interact = false
		if Player.is_in_an_area():
			Player.set_in_an_area(false)
		if is_object:
			Player.show_interact(false)
		else:
			interact.hide()


func _on_Sprite_frame_changed():
	if walking and (spr.get_frame() % 2 == 0):
		_play_footstep_sound()
