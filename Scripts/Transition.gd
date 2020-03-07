extends Area2D

export(String, FILE, "*.tscn") var target_scene
export(Player.Direction) var target_direction

const TimeMax: int = 5

var loader: ResourceInteractiveLoader
var loaded_scene: PackedScene = null

# =====================================================================

func _ready():
	loader = ResourceLoader.load_interactive(target_scene, "PackedScene")
	if loader == null:
		push_error("Failed to load scene %s" % target_scene)
		set_process(false)
		return
	
	
func _process(delta):
	if loader == null:
		set_process(false)
		
	var t = OS.get_ticks_msec()
	while OS.get_ticks_msec() < t + TimeMax:
		var err := loader.poll()
		
		if err == ERR_FILE_EOF:
			loaded_scene = loader.get_resource() as PackedScene
			loader = null
			set_process(false)
			break
		elif err != OK:
			push_error("Failed to load scene %s" % target_scene)
			loader = null
			break

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
