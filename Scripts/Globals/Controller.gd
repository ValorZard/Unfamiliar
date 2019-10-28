extends Node

const DialogueRef := preload("res://Instances/Dialogue.tscn")
const DiscourseStartRef := preload("res://Scenes/DiscourseStart.tscn")
const CosmoSprite := preload("res://Resources/Sprite Frames/SpriteFrames_Cosmo.tres")
const RhonaSprite := preload("res://Resources/Sprite Frames/SpriteFrames_Rhona.tres")
const DiscourseScene := "res://Scenes/Discourse.tscn"
const SoundOneShotRef := preload("res://Instances/SoundOneShot.tscn")
const MenuRef := preload("res://Instances/System/Menu.tscn")

const FlashbackPath := "res://Instances/System/Flashback.tscn"

var inventory := {}
var flags: Dictionary = {
	"scn_intro": 0,
	
	"npc_train_rudeman": 0,
	"npc_train_unsurewoman": 0,
	
	"choice_hometown": 0, # 0 = Salem, 1 = Zzyzx, 2 = Cottonwood
	"choice_know_rhona's_grandpa": 0, # 0 = No, 1 = Yes
	"choice_witch_profession": 0, # 0 = Teacher, 1 = Potions, 2 = Books
	"choice_witch_personality": 0, # 0 = Good, 1 = Okay, 2 = Bad
}

var money: int = 20
var money_disp: int = 20

var menu_open := false

var d_previous_scene: String
var d_previous_pos: Vector2
var d_previous_dir: int
var d_previous_npc: EventNPC = null

onready var money_text: Label = $Overlay/Money
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var anim_player_fade: AnimationPlayer = $AnimationPlayerFade

# =====================================================================

func _ready():
	var f := File.new()
	if not f.file_exists("user://Hello.txt"):
		f.open("user://Hello.txt", File.WRITE)
		f.store_line("Hello. Please don't edit these files. You'll make Cosmo very upset. Thanks.")
		if f.is_open():
			f.close()

func _process(delta):
	if money_disp != money:
		money_disp = lerp(money_disp, money, 0.15)
	
	money_text.text = str(money_disp)
	
	if Input.is_action_just_pressed("sys_menu") and not menu_open:
		menu_open = true
		Player.set_state(Player.PlayerState.NoInput)
		var menu := MenuRef.instance()
		get_tree().get_root().add_child(menu)
		
	if Input.is_action_just_pressed("sys_fullscreen"):
		OS.set_window_fullscreen(not OS.is_window_fullscreen())
		
	#if Input.is_action_just_pressed("debug_1"):
	#	save_game(0)
		
	#if Input.is_action_just_pressed("debug_2"):
	#	load_game(0)

# =====================================================================

func flag(key: String) -> int:
	return flags[key]
	

func set_flag(key: String, value: int):
	flags[key] = value
	
	
func get_previous_scene() -> String:
	return d_previous_scene
	
	
func get_previous_pos() -> Vector2:
	return d_previous_pos
	
	
func get_previous_dir() -> int:
	return d_previous_dir
	
	
func get_previous_npc() -> EventNPC:
	return d_previous_npc
	
	
func set_previous_npc(npc: EventNPC):
	d_previous_npc = npc
	
	
func set_menu_open(value: bool):
	menu_open = value
	
	
func fade(time: float, fadeout: bool, color: Color = Color(0, 0, 0), above_overlay: bool = false):
	$CanvasLayer.set_layer(3 if above_overlay else 0)
	
	var anim: Animation = anim_player_fade.get_animation("Fadeout" if fadeout else "Fadein")
	if fadeout:
		anim.track_set_key_value(0, 0, Color(color.r, color.g, color.b, 0.0))
		anim.track_set_key_value(0, 1, Color(color.r, color.g, color.b, 1.0))
	else:
		anim.track_set_key_value(0, 0, Color(color.r, color.g, color.b, 1.0))
		anim.track_set_key_value(0, 1, Color(color.r, color.g, color.b, 0.0))
	
	anim_player_fade.set_speed_scale(1.0 / time)
	anim_player_fade.play("Fadeout" if fadeout else "Fadein")


func goto_scene(path: String, pos: Vector2, direction: int, transition: bool, relative_coords: bool = true):
	if transition:
		Player.set_state(Player.PlayerState.NoInput)
		var current_scene := get_tree().get_root().get_node("Scene")
		var scn: PackedScene = load(path)
		var scn_i := scn.instance()
		
		var target: Vector2
		var player_offset: Vector2
		match direction:
			Player.Direction.Up:
				target = Vector2(0, -144)
				player_offset = Vector2(0, -8)
			Player.Direction.Down:
				target = Vector2(0, 144)
				player_offset = Vector2(0, 8)
			Player.Direction.Left:
				target = Vector2(-160, 0)
				player_offset = Vector2(-8, 0)
			Player.Direction.Right:
				target = Vector2(160, 0)
				player_offset = Vector2(8, 0)
		scn_i.set_position(target)
		get_tree().get_root().add_child(scn_i)
		
		anim_player.get_animation("CameraScroll").track_set_key_value(0, 1, target)
		anim_player.play("CameraScroll")
		Player.scroll_offset(player_offset)
		yield(anim_player, "animation_finished")
		
		current_scene.set_name("__temp")
		scn_i.set_name("Scene")
		current_scene.queue_free()
		
		Player.position -= target
		scn_i.set_position(Vector2.ZERO)
		$MainCamera.set_offset(Vector2.ZERO)
		
		Player.set_state(Player.PlayerState.Move)
	else:
		var current_scene := get_tree().get_root().get_node("Scene")
		var scn: PackedScene = load(path) as PackedScene
		var scn_i := scn.instance()
		get_tree().get_root().add_child(scn_i)
		current_scene.set_name("__temp")
		scn_i.set_name("Scene")
		current_scene.queue_free()
		
		
func save_game(slot: int):
	var f := File.new()
	var fname := "user://data_s" + str(slot + 1) + ".uf"
	if f.file_exists(fname):
		var dir := Directory.new()
		dir.remove(fname)
	f.open(fname, File.WRITE)
	f.store_line(get_tree().get_current_scene().get_filename())
	f.store_line(str(Player.get_position().x))
	f.store_line(str(Player.get_position().y))
	f.store_line(str(Player.get_direction()))
	f.store_line(str(money))
	f.store_line(to_json(flags))
	if f.is_open():
		f.close()


func load_game(slot: int):
	var f := File.new()
	f.open("user://data_" + str(slot + 1) + ".uf", File.READ)
	var scn: String
	var pos: Vector2 = Vector2(0, 0)
	var dir: int
	
	scn = f.get_line()
	pos.x = float(f.get_line())
	pos.y = float(f.get_line())
	dir = int(f.get_line())
	money = int(f.get_line())
	flags = parse_json(f.get_line())
	
	if f.is_open():
		f.close()

	get_tree().change_scene(scn)
	Player.set_position(pos)
	Player.set_direction(dir)


func get_money() -> int:
	return money
	
	
func add_money(amount: int):
	money += amount
	

func play_sound_oneshot(sound: AudioStream, pitch: float = 1.0, volume: float = 0.0):
	var i := SoundOneShotRef.instance() as AudioStreamPlayer
	i.set_stream(sound)
	i.set_pitch_scale(pitch)
	i.set_volume_db(volume)
	i.play()
	get_tree().get_root().add_child(i)
	

func play_sound_oneshot_from_path(sound: String, pitch: float = 1.0, volume: float = 0.0):
	var i := SoundOneShotRef.instance() as AudioStreamPlayer
	i.set_stream(load(sound) as AudioStream)
	i.set_pitch_scale(pitch)
	i.set_volume_db(volume)
	i.play()
	get_tree().get_root().add_child(i)
	
	
func dialogue(file: String, set: int, reset_state: bool = true) -> Dialogue:
	var dlg: Dialogue = DialogueRef.instance() as Dialogue
	dlg.start(file, set, reset_state)
	get_tree().get_root().add_child(dlg)
	return dlg
	
	
func flashback(file: String, art: Texture) -> Flashback:
	var fb: PackedScene = load(FlashbackPath)
	var fb_i = fb.instance() as Flashback
	fb_i.set_fb_file(file)
	fb_i.set_art(art)
	get_tree().get_root().add_child(fb_i)
	fb_i.start()
	return fb_i


func start_discourse(file: String, right_name: String, right_sprite: SpriteFrames, left_name: String = "Cosmo", left_sprite: SpriteFrames = CosmoSprite):
	Player.set_state(Player.PlayerState.NoInput)
	
	d_previous_scene = get_tree().get_current_scene().get_filename()
	d_previous_pos = Player.get_position()
	d_previous_dir = Player.get_direction()
	
	var start := DiscourseStartRef.instance()
	start.set_position(Vector2.ZERO)
	get_tree().get_root().add_child(start)
	yield(get_tree().create_timer(4.5), "timeout")
	draw_overlay(false)
	goto_scene(DiscourseScene, Vector2.ZERO, Player.Direction.Down, false)
	yield(get_tree().create_timer(0.02), "timeout")
	Player.hide()
	get_tree().get_root().get_node("Scene").run_discourse(file, right_name, right_sprite, left_name, left_sprite)
	
	
func draw_overlay(draw: bool):
	$Overlay/Sprite.set_visible(draw)
	$Overlay/Money.set_visible(draw)

# =====================================================================

func goto_scene_post(pos: Vector2, direction: int):
	yield(get_tree(), "idle_frame")
	var p := Player
	p.set_position(pos)
	p.set_direction(direction)
