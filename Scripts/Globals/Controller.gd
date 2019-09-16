extends Node

const DiscourseStartRef := preload("res://Scenes/DiscourseStart.tscn")
const CosmoSprite := preload("res://Resources/Sprite Frames/SpriteFrames_Cosmo.tres")
const CosmoSprite2 := preload("res://Resources/Sprite Frames/SpriteFrames_Cosmo2.tres")
const DiscourseScene := "res://Scenes/Discourse.tscn"

# =====================================================================

func _ready():
	pass
	
	
func _process(delta):
	if Input.is_action_just_pressed("debug_1"):
		start_discourse("res://Discourses/Test.txt", "Rhona", CosmoSprite2)

# =====================================================================

func start_discourse(file: String, right_name: String, right_sprite: SpriteFrames, left_name: String = "Cosmo", left_sprite: SpriteFrames = CosmoSprite):
	var start := DiscourseStartRef.instance()
	start.set_position(Vector2.ZERO)
	get_tree().get_root().add_child(start)
	yield(get_tree().create_timer(4.5), "timeout")
	get_tree().change_scene(DiscourseScene)
	yield(get_tree().create_timer(0.02), "timeout")
	get_tree().get_root().get_node("Discourse").run_discourse(file, right_name, right_sprite, left_name, left_sprite)
