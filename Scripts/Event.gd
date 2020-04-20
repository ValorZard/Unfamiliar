extends Area2D

class_name Event

signal event_ended

export(bool) var in_npc := false
export(bool) var autostart := false

var started := false
var current_index: int = 0
var jump_point: float = NAN

onready var anim_player := $AnimationPlayer as AnimationPlayer

# =====================================================================

func _ready():
	if autostart and not Controller.is_mid_event():
		Player.set_state(Player.PlayerState.NoInput)
		(get_node("TimerStart") as Timer).start()
		
		
func _exit_tree():
	if not Player.is_in_transition() and not Player.is_in_door_transition():
		Player.set_state(Player.PlayerState.Move)

# =====================================================================
	
func start_event(index: int = 0, position: float = 0.0):
	if not started:
		Player.set_state(Player.PlayerState.NoInput)
		Player.show_interact(false)
		Player.set_in_event(true)
		
		anim_player.play("Event" + (str(index + 1) if index != 0 else ""))
		anim_player.seek(position)

		current_index = index
		started = true
		Controller.set_mid_event(true)
	
# =====================================================================

func _event_set_flag(key: String, value: int):
	Controller.set_flag(key, value)
	
	
func _event_increment_flag(key: String):
	var val: int = Controller.flag(key)
	Controller.set_flag(key, val + 1)
	
	
func _event_conditional_jump(flag: String, value: int, time: float, not_equal: bool = false):
	if not_equal and Controller.flag(flag) != value:
		anim_player.seek(time)
	elif not not_equal and Controller.flag(flag) == value:
		anim_player.seek(time)


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
	yield(Controller.wait(time), "timeout")
	anim_player.play()
	

func _event_move_player_sequence(positions: PoolVector2Array, times: PoolRealArray, directions: PoolIntArray):
	anim_player.stop(false)
	#assert len(positions) == len(times) == len(directions)
	for i in range(len(positions)):
		__move_character(Player, positions[i], times[i], directions[i])
		yield(Controller.wait(times[i]), "timeout")
	Player.set_speed_override(0)
	anim_player.play()

	
func _event_move_player_to_position(pos: Vector2, time: float, direction: int):
	anim_player.stop(false)
	__move_character(Player, pos, time, direction)
	yield(Controller.wait(time), "timeout")
	Player.set_speed_override(0)
	anim_player.play()
	
	
func _event_move_npc_sequence(npc: NodePath, positions: PoolVector2Array, times: PoolRealArray, directions: PoolIntArray):
	anim_player.stop(false)
	#assert len(positions) == len(times) == len(directions)
	var npc_ref := get_node(npc)
	for i in range(len(positions)):
		__move_character(npc_ref, positions[i], times[i], directions[i])
		yield(Controller.wait(times[i]), "timeout")
	npc_ref.set_speed_override(0)
	anim_player.play()
	
	
func _event_move_npc_to_position(npc: NodePath, pos: Vector2, time: float, direction: int):
	anim_player.stop(false)
	var npc_ref := get_node(npc)# as EventNPC
	__move_character(npc_ref, pos, time, direction)
	yield(Controller.wait(time), "timeout")
	npc_ref.set_speed_override(0)
	anim_player.play()
	
	
func _event_teleport_player(pos: Vector2):
	Player.set_position(pos)
	

func _event_dialogue(file: String, set: int, text_size: int = 8, alt_box: bool = false):
	anim_player.stop(false)
	var dlg: Dialogue = Controller.dialogue(file, set, alt_box, text_size, false)
	dlg.connect("dialogue_ended_jump", self, "__set_jump_point")
	yield(dlg, "dialogue_ended")
	
	if not is_nan(jump_point):
		anim_player.seek(jump_point)
	anim_player.play()
	
	
#func _event_dialogue_conditional(file: String, flag_: String, table: Dictionary, text_size: int = 8):
#	anim_player.stop(false)
#	yield(Controller.dialogue(file, table[Controller.flag(flag_)], false, text_size, false), "dialogue_ended")
#	anim_player.play()
	
	
func _event_flashback(file: String, texture: String, transition: bool = true):
	anim_player.stop(false)
	yield(Controller.flashback(file, load(texture), transition), "flashback_finished")
	anim_player.play()
	

func _event_discourse(full_name: String, file: String, right_name: String, right_sprite: String):
	anim_player.stop(false)
	Controller.set_previous_event(get_path())
	Controller.set_previous_event_index(current_index)
	Controller.set_previous_event_pos(anim_player.get_current_animation_position())
	Controller.start_discourse(full_name, file, right_name, right_sprite)
	

func _event_play_sound(sound_path: String):
	Controller.play_sound_oneshot_from_path(sound_path)
	
	
func _event_play_music(music: AudioStream, pitch: float = 1.0, volume: int = 0):
	Controller.play_music(music)
	
	
func _event_play_ambient(amb: AudioStream, pitch: float = 1.0, volume: int = 0):
	Controller.play_ambient(amb, pitch, volume)
	

func _event_add_money(amount: int):
	Controller.add_money(amount)
	
	
func _event_advance_game_time():
	Controller.advance_game_time()

# =====================================================================

func _event_intro_replace_player(old_player: NodePath):
	Player.set_position(Vector2(208, 84))
	Player.show()
	get_node(old_player).queue_free()

# =====================================================================

func __move_character(character: Node2D, pos: Vector2, time: float, direction: int):
	character.set_direction(direction)
	var dir = character.get_position().direction_to(pos)
	if dir.x < 0:
		if dir.y < 0:
			match direction:
				Player.Direction.Up:
					character.set_vel_override(Vector2(0, -1))
				Player.Direction.Left:
					character.set_vel_override(Vector2(-1, 0))
				_:
					character.set_vel_override(Vector2(0, -1))
		else:
			match direction:
				Player.Direction.Down:
					character.set_vel_override(Vector2(0, 1))
				Player.Direction.Left:
					character.set_vel_override(Vector2(-1, 0))
				_:
					character.set_vel_override(Vector2(0, 1))
	else:
		if dir.y < 0:
			match direction:
				Player.Direction.Up:
					character.set_vel_override(Vector2(0, -1))
				Player.Direction.Right:
					character.set_vel_override(Vector2(1, 0))
				_:
					character.set_vel_override(Vector2(0, -1))
		else:
			match direction:
				Player.Direction.Down:
					character.set_vel_override(Vector2(0, 1))
				Player.Direction.Right:
					character.set_vel_override(Vector2(1, 0))
				_:
					character.set_vel_override(Vector2(0, 1))
					
	character.set_speed_override(character.get_position().distance_to(pos) / time)
	
	
func __set_jump_point(value: float):
	jump_point = value

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
		
		#if auto_set_destroy:
		#	Controller.set_flag(destroy_flag, 1)
		
		started = false
		Controller.set_mid_event(false)
		if not in_npc:
			queue_free()


func _on_TimerStart_timeout():
	start_event()
