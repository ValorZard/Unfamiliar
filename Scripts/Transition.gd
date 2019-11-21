extends Area2D

export(String, FILE, "*.tscn") var target_scene
export(Player.Direction) var target_direction

# =====================================================================

func _on_Transition_body_entered(body: PhysicsBody2D):
	if body != null:
		if body.is_in_group("Player") and Player.get_state() == Player.PlayerState.Move:
			Player.set_direction(target_direction)
			yield(get_tree(), "physics_frame")
			Controller.goto_scene(target_scene, Vector2.ZERO, target_direction, true)
