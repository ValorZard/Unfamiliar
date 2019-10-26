extends Area2D

export(bool) var autostart = false
export(bool) var destroy
export(String) var destroy_flag

var started := false

func _ready():
	if destroy and Controller.flag(destroy_flag) == 1:
		queue_free()
		
	if autostart:
		start_event()
	
# =====================================================================
	
func start_event():
	if not started:
		Player.set_state(Player.PlayerState.NoInput)
		$AnimationPlayer.play("Event")
		started = true
	
# =====================================================================

func _event_set_flag(key: String, value: int):
	Controller.set_flag(key, value)


func _event_show_player(show: bool):
	Player.set_visible(show)
	

func _event_dialogue(file: String, set: int):
	$AnimationPlayer.stop(false)
	yield(Controller.dialogue(file, set, false), "dialogue_ended")
	$AnimationPlayer.play()
	

func _event_play_sound(sound_path: String):
	Controller.play_sound_oneshot_from_path(sound_path)

# =====================================================================

func _event_intro_replace_player(old_player: NodePath):
	Player.set_position(Vector2(208, 84))
	Player.show()
	get_node(old_player).queue_free()

# =====================================================================

func _on_Event_body_entered(body: PhysicsBody2D):
	if body != null:
		if body.is_in_group("Player") and Player.get_state() == Player.PlayerState.Move:
			start_event()
	

func _on_AnimationPlayer_animation_finished(anim_name: String):
	if anim_name == "Event":
		Player.set_state(Player.PlayerState.Move)
		queue_free()
