extends Area2D

export(String, FILE, "*.tscn") var target_scene
export(Vector2) var target_position
export(Player.Direction) var target_direction
export(AudioStream) var door_sound
export(Color) var fade_color = Color(0, 0, 0)
export(float) var fade_time = 0.5

var in_area := false

func _process(delta):
	if Input.is_action_just_pressed("sys_action") and in_area:
		Controller.play_sound_oneshot(door_sound)
		Player.set_state(Player.PlayerState.NoInput)
		Controller.fade(fade_time, true, fade_color)
		yield(get_tree().create_timer(fade_time), "timeout")
		Controller.goto_scene(target_scene, target_position, target_direction, false, false)
		Player.set_position(target_position)
		Controller.fade(fade_time, false, fade_color)
		Player.set_state(Player.PlayerState.Move)
		


func _on_Door_body_entered(body: PhysicsBody2D):
	if body != null:
		if body.is_in_group("Player"):
			in_area = true


func _on_Door_body_exited(body: PhysicsBody2D):
	if body != null:
		if body.is_in_group("Player"):
			in_area = false
