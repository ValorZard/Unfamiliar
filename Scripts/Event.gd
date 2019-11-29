extends Area2D

class_name Event

signal event_ended

export(bool) var in_npc = false
export(bool) var autostart = false
export(bool) var destroy
export(String) var destroy_flag
export(bool) var auto_set_destroy = false
export(NodePath) var discourse_npc = null

var started := false

onready var anim_player := $AnimationPlayer as AnimationPlayer

# =====================================================================

func _ready():
	if destroy and Controller.flag(destroy_flag) == 1:
		queue_free()
	elif autostart:
		start_event()
	
# =====================================================================
	
func start_event(index: int = 0):
	if not started:
		Player.set_state(Player.PlayerState.NoInput)
		Player.show_interact(false)
		Player.set_in_event(true)
		anim_player.play("Event" + (str(index + 1) if index != 0 else ""))
		if discourse_npc != null:
			Controller.set_previous_npc(get_node(discourse_npc).get_path())
		if auto_set_destroy:
			Controller.set_flag(destroy_flag, 1)
		started = true
	
# =====================================================================

func _event_set_flag(key: String, value: int):
	Controller.set_flag(key, value)


func _event_show_player(show: bool):
	Player.set_visible(show)
	
	
func _event_set_player_direction(direction: int):
	Player.set_sprite_override(false)
	Player.set_direction(direction)
	
	
func _event_player_sprite_override(value: bool):
	Player.set_sprite_override(value)
	
	
func _event_player_play_animation(anim: String):
	Player.set_sprite_override(true)
	Player.play_sprite_animation(anim)
	
	
func _event_fade(time: float, fadeout: bool, color: Color = Color(0, 0, 0), above_overlay: bool = false):
	anim_player.stop(false)
	Controller.fade(time, fadeout, color, above_overlay)
	yield(get_tree().create_timer(time), "timeout")
	anim_player.play()
	

func _event_move_player_sequence(positions: PoolVector2Array, times: PoolRealArray, directions: PoolIntArray):
	anim_player.stop(false)
	#assert len(positions) == len(times) == len(directions)
	for i in range(len(positions)):
		__move_player(positions[i], times[i], directions[i])
		yield(get_tree().create_timer(times[i]), "timeout")
	Player.set_speed_override(0)
	anim_player.play()

	
func _event_move_player_to_position(pos: Vector2, time: float, direction: int):
	anim_player.stop(false)
	__move_player(pos, time, direction)
	yield(get_tree().create_timer(time), "timeout")
	Player.set_speed_override(0)
	anim_player.play()
	
	
func _event_teleport_player(pos: Vector2):
	Player.set_position(pos)
	

func _event_dialogue(file: String, set: int, text_size: int = 8):
	anim_player.stop(false)
	yield(Controller.dialogue(file, set, text_size, false), "dialogue_ended")
	anim_player.play()
	
	
func _event_dialogue_conditional(file: String, flag_: String, table: Dictionary, text_size: int = 8):
	anim_player.stop(false)
	yield(Controller.dialogue(file, table[Controller.flag(flag_)], text_size, false), "dialogue_ended")
	anim_player.play()
	
	
func _event_flashback(file: String, texture: String, transition: bool = true):
	anim_player.stop(false)
	yield(Controller.flashback(file, load(texture), transition), "flashback_finished")
	anim_player.play()
	

func _event_discourse(full_name: String, file: String, right_name: String, right_sprite: String):
	anim_player.stop(false)
	Controller.start_discourse(full_name, file, right_name, load(right_sprite) as SpriteFrames)
	

func _event_play_sound(sound_path: String):
	Controller.play_sound_oneshot_from_path(sound_path)

# =====================================================================

func _event_intro_replace_player(old_player: NodePath):
	Player.set_position(Vector2(208, 84))
	Player.show()
	get_node(old_player).queue_free()

# =====================================================================

func __move_player(pos: Vector2, time: float, direction: int):
	Player.set_direction(direction)
	var dir = Player.get_position().direction_to(pos)
	if dir.x < 0:
		if dir.y < 0:
			match direction:
				Player.Direction.Up:
					Player.set_vel_override(Vector2(0, -1))
				Player.Direction.Left:
					Player.set_vel_override(Vector2(-1, 0))
				_:
					Player.set_vel_override(Vector2(0, -1))
		else:
			match direction:
				Player.Direction.Down:
					Player.set_vel_override(Vector2(0, 1))
				Player.Direction.Left:
					Player.set_vel_override(Vector2(-1, 0))
				_:
					Player.set_vel_override(Vector2(0, 1))
	else:
		if dir.y < 0:
			match direction:
				Player.Direction.Up:
					Player.set_vel_override(Vector2(0, -1))
				Player.Direction.Right:
					Player.set_vel_override(Vector2(1, 0))
				_:
					Player.set_vel_override(Vector2(0, -1))
		else:
			match direction:
				Player.Direction.Down:
					Player.set_vel_override(Vector2(0, 1))
				Player.Direction.Right:
					Player.set_vel_override(Vector2(1, 0))
				_:
					Player.set_vel_override(Vector2(0, 1))
					
	Player.set_speed_override(Player.get_position().distance_to(pos) / time)
	

# =====================================================================

func _on_Event_body_entered(body: PhysicsBody2D):
	if body != null:
		if body.is_in_group("Player") and Player.get_state() == Player.PlayerState.Move:
			start_event()
	

func _on_AnimationPlayer_animation_finished(anim_name: String):
	if anim_name.substr(0, 5) == "Event":
		Player.set_state(Player.PlayerState.Move)
		Player.set_in_event(false)
		emit_signal("event_ended")
		
		started = false
		if not in_npc:
			queue_free()
