extends Node

const DiscourseStartRef := preload("res://Scenes/DiscourseStart.tscn")
const CosmoSprite := preload("res://Resources/Sprite Frames/SpriteFrames_Cosmo.tres")
const CosmoSprite2 := preload("res://Resources/Sprite Frames/SpriteFrames_Cosmo2.tres")
const DiscourseScene := "res://Scenes/Discourse.tscn"

var inventory := {}

var money: int = 20
var money_disp: int = 20

enum PlayerState { Move, NoInput }

var player_state: int = PlayerState.Move

onready var money_text: Label = $Overlay/Money

# =====================================================================

func _process(delta):
	if Input.is_action_just_pressed("debug_1"):
		start_discourse("res://Discourses/d_1_rhona.txt", "Rhona", CosmoSprite2)
		
	if money_disp != money:
		money_disp = lerp(money_disp, money, 0.15)
	
	money_text.text = str(money_disp)

# =====================================================================

func set_player_state(value: int):
	get_tree().get_root().get_node("Scene").get_node("Player").set_state(value)
	

func get_money() -> int:
	return money
	
	
func add_money(amount: int):
	money += amount


func start_discourse(file: String, right_name: String, right_sprite: SpriteFrames, left_name: String = "Cosmo", left_sprite: SpriteFrames = CosmoSprite):
	var start := DiscourseStartRef.instance()
	start.set_position(Vector2.ZERO)
	get_tree().get_root().add_child(start)
	yield(get_tree().create_timer(4.5), "timeout")
	draw_overlay(false)
	get_tree().change_scene(DiscourseScene)
	yield(get_tree().create_timer(0.02), "timeout")
	get_tree().get_root().get_node("Discourse").run_discourse(file, right_name, right_sprite, left_name, left_sprite)
	
	
func draw_overlay(draw: bool):
	$Overlay/Sprite.set_visible(draw)
	$Overlay/Money.set_visible(draw)
