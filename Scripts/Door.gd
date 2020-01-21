extends Area2D

const DoorTransitionRef := "res://Instances/System/DoorTransition.tscn"

export(String, FILE, "*.tscn") var target_scene
export(Vector2) var target_position
export(Player.Direction) var target_direction
export(AudioStream) var door_sound = null
#export(bool) var restore_control = true

var in_area := false

# =====================================================================

func _process(delta):
	if Input.is_action_just_pressed("sys_action") and in_area and Player.get_state() == Player.PlayerState.Move:
		if door_sound != null:
			Controller.play_sound_oneshot(door_sound)
			
		Player.set_state(Player.PlayerState.NoInput)
		Player.show_interact(false)
		var transition := (load(DoorTransitionRef) as PackedScene).instance()
		get_tree().get_root().add_child(transition)
		yield(Controller.wait(0.6), "timeout")
		Controller.goto_scene(target_scene, target_position, target_direction, false, false)
		var ap: AnimationPlayer = transition.get_node("AnimationPlayer") as AnimationPlayer
		ap.play("Fadein")
		ap.connect("animation_finished", transition, "destroy")
		ap.connect("animation_finished", transition, "restore_player_movement")
		
# =====================================================================

func _on_Door_body_entered(body: PhysicsBody2D):
	if body != null:
		if body.is_in_group("Player") and Player.get_state() == Player.PlayerState.Move and not Player.is_in_an_area():
			Player.show_interact(true)
			Player.set_in_an_area(true)
			in_area = true


func _on_Door_body_exited(body: PhysicsBody2D):
	if body != null:
		if body.is_in_group("Player"):
			Player.show_interact(false)
			if Player.is_in_an_area():
				Player.set_in_an_area(false)
			in_area = false
