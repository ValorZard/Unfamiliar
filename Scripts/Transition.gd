extends Area2D

export(String, FILE, "*.tscn") var target_scene
export(Player.Direction) var target_direction

var loaded_scene: Node2D = null

onready var thread := Thread.new()

# =====================================================================

func _ready():
	SceneLoader.queue_scene(target_scene)
	SceneLoader.connect("scene_loaded", self, "set_loaded_scene", [], CONNECT_REFERENCE_COUNTED)
	

func _exit_tree():
	if loaded_scene != null and not loaded_scene.is_inside_tree():
		loaded_scene.free()

# =====================================================================	

func set_loaded_scene(scene: Node2D, path: String):
	if path == target_scene:
		loaded_scene = scene
	
# =====================================================================	

func _on_Transition_body_entered(body: PhysicsBody2D):
	if body != null:
		if body.is_in_group("Player") and Player.get_state() == Player.PlayerState.Move:
			Player.set_direction(target_direction)
			yield(get_tree(), "physics_frame")
			if loaded_scene == null:
				Controller.goto_scene(target_scene, Vector2.ZERO, target_direction, true)
			else:
				Controller.goto_scene("", Vector2.ZERO, target_direction, true, true, true, loaded_scene)
