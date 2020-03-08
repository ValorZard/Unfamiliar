extends Area2D

const DoorTransitionRef := "res://Instances/System/DoorTransition.tscn"

export(String, FILE, "*.tscn") var target_scene
export(Vector2) var target_position
export(Player.Direction) var target_direction
export(AudioStream) var door_sound = null

var loaded_scene: Node2D = null

var in_area := false

# =====================================================================

func _ready():
	SceneLoader.queue_scene(target_scene)
	SceneLoader.connect("scene_loaded", self, "set_loaded_scene", [], CONNECT_REFERENCE_COUNTED)
	

func _process(delta):
	if Input.is_action_just_pressed("sys_action") and in_area and Player.get_state() == Player.PlayerState.Move:
		if door_sound != null:
			Controller.play_sound_oneshot(door_sound)
			
		Player.set_state(Player.PlayerState.NoInput)
		Player.show_interact(false)
		var transition := (load(DoorTransitionRef) as PackedScene).instance()
		get_tree().get_root().add_child(transition)
		yield(Controller.wait(0.6), "timeout")
		
		if loaded_scene == null:
			Controller.goto_scene(target_scene, target_position, target_direction, false, false)
		else:
			Controller.goto_scene("", target_position, target_direction, false, false, true, loaded_scene)
			
		var ap: AnimationPlayer = transition.get_node("AnimationPlayer") as AnimationPlayer
		ap.play("Fadein")
		ap.connect("animation_finished", transition, "destroy")
		ap.connect("animation_finished", transition, "restore_player_movement")
		
# =====================================================================

func set_loaded_scene(scene: Node2D, path: String):
	if path == target_scene:
		loaded_scene = scene

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
