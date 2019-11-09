extends Node

const DialogueRef := "res://Instances/Dialogue.tscn"
const DiscourseStartRef := "res://Scenes/DiscourseStart.tscn"
const CosmoSprite := "res://Resources/Sprite Frames/SpriteFrames_Cosmo.tres"
const DiscourseScene := "res://Scenes/Discourse.tscn"
const MenuRef := "res://Instances/System/Menu.tscn"
const FlashbackRef := "res://Instances/System/Flashback.tscn"

const SoundOneShotRef := preload("res://Instances/SoundOneShot.tscn")
const ItemRef := preload("res://Instances/System/Item.tscn")

#var inventory := []

var flags: Dictionary = {
	# ========================================
	# SCENES
	# ========================================
	"scn_intro": 0,
	"scn_rhona": 0,
	"scn_lm_intro": 0,
	# ========================================
	# NPCS
	# ========================================
	"npc_train_rudeman": 0,
	"npc_train_unsurewoman": 0,
	"npc_train_rhona": 0,
	# ----------------------------------------
	"npc_lm_guide": 0,
	"npc_lm_pace": 0,
	# ========================================
	# DIALOGUE CHOICES
	# ========================================
	"choice_hometown": 0, # 0 = Salem, 1 = Zzyzx, 2 = Cottonwood
	"choice_know_rhona's_grandpa": 0, # 0 = No, 1 = Yes
	"choice_witch_profession": 0, # 0 = Teacher, 1 = Potions, 2 = Books
	"choice_witch_personality": 0, # 0 = Good, 1 = Okay, 2 = Bad
	# ----------------------------------------
	"choice_witch_socialness": 0, # 0 = Social, 1 = Sort of, 2 = Recluse
}

var settings: Dictionary = {
	"window_size": 0, # 0 = 1x, 1 = 2x, 2 = 3x
	"fullscreen": 0, # 0 = No, 1 = Yes
	"controller_buttons": 0, # 0 = XBox, 1 = PS, 2 = Switch
	"text_speed_overworld": 1, # 0 = Slow, 1 = Medium, 2 = Fast
	"text_speed_discourse": 2 # 0 = Slow, 1 = Medium, 2 = Fast
}

const map_marker_locs: Dictionary = {
	"res://Scenes/Los Muertos/LM_Trainstation.tscn":   Vector2(3, 4),
	"res://Scenes/Los Muertos/LM_Crossroads.tscn":     Vector2(3, 3),
	"res://Scenes/Los Muertos/LM_Waterfront_R1.tscn":  Vector2(4, 3),
	"res://Scenes/Los Muertos/LM_Waterfront_L1.tscn":  Vector2(2, 3),
	"res://Scenes/Los Muertos/LM_Mainstreet_S.tscn":   Vector2(3, 2),
	"res://Scenes/Los Muertos/LM_Mainstreet_N.tscn":   Vector2(3, 1),
	"res://Scenes/Los Muertos/LM_Square.tscn":         Vector2(3, 0),
	"res://Scenes/Los Muertos/LM_Mainstreet_R.tscn":   Vector2(4, 1),
	"res://Scenes/Los Muertos/LM_Eastside_3.tscn":     Vector2(5, 1),
	"res://Scenes/Los Muertos/LM_Hideout.tscn":        Vector2(5, 0),
	"res://Scenes/Los Muertos/LM_Thoroughfare_R.tscn": Vector2(2, 1),
}

var money: int = 20
var money_disp: int = 20

var menu_open := false

var d_previous_scene: String
var d_previous_pos: Vector2
var d_previous_dir: int
var d_previous_npc: NodePath

var controller_connected: bool = false

onready var money_text: Label = $Overlay/CanvasLayer/Money
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var anim_player_fade: AnimationPlayer = $AnimationPlayerFade

# =====================================================================

func _init():
	#match settings["window_size"]:
	#	0:
	#		OS.set_window_size(Vector2(1280, 720))
	#	1:
	#		OS.set_window_size(Vector2(1920, 1080))
	#	2:
	#		OS.set_window_size(Vector2(2560, 1440))
		
	#OS.center_window()
	
	if settings["fullscreen"] == 1:
		OS.set_window_fullscreen(true)
	

func _ready():
	#var f := File.new()
	#if not f.file_exists("user://Hello.txt"):
	#	f.open("user://Hello.txt", File.WRITE)
	#	f.store_line("Hello. Please don't edit these files. You'll make Cosmo very upset. Thanks.")
	#	if f.is_open():
	#		f.close()
	
	#var rt := get_tree().get_root()
	
	controller_connected = len(Input.get_connected_joypads()) > 0
	Input.connect("joy_connection_changed", self, "controller_connection")


func _process(delta):
	if money_disp != money:
		money_disp = lerp(money_disp, money, 0.15)
	
	money_text.text = str(money_disp)
	
	if Input.is_action_just_pressed("sys_menu") and not menu_open:
		menu_open = true
		Player.set_state(Player.PlayerState.NoInput)
		var menu := (load(MenuRef) as PackedScene).instance()
		get_tree().get_root().add_child(menu)
		
	if Input.is_action_just_pressed("sys_fullscreen"):
		OS.set_window_fullscreen(not OS.is_window_fullscreen())

# =====================================================================

func flag(key: String) -> int:
	return flags[key]
	

func set_flag(key: String, value: int):
	flags[key] = value
	
	
func get_scene_map_marker(scene: String) -> Vector2:
	return map_marker_locs.get(scene)
	
	
func get_previous_scene() -> String:
	return d_previous_scene
	
	
func get_previous_pos() -> Vector2:
	return d_previous_pos
	
	
func get_previous_dir() -> int:
	return d_previous_dir
	
	
func get_previous_npc() -> NodePath:
	return d_previous_npc
	
	
func set_previous_npc(npc: NodePath):
	d_previous_npc = npc
	
	
func set_menu_open(value: bool):
	menu_open = value
	
	
func post_discourse():
	Player.set_state(Player.PlayerState.Move)
	(get_node(d_previous_npc) as EventNPC).show_interact(true)
	
	
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
		Player.set_in_transition(true)
		var current_scene := get_tree().get_root().get_node("Scene")
		var scn: PackedScene = load(path) as PackedScene
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
		
		var loc: Vector2 = map_marker_locs.get(path)
		$Overlay/CanvasLayer/Map/Marker.set_position(Vector2(4 + 8 * loc.x, 3 + 6 * loc.y) if loc != null else Vector2(4, 3))
		
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
		
		Player.set_in_transition(false)
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
	

func add_item(name: String, desc: String, picture: Texture):
	var t: TextureRect = ItemRef.instance() as TextureRect
	t.set_texture(picture)
	$Overlay/CanvasLayer/Inventory.add_child(t)
	

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
	var dlg: Dialogue = (load(DialogueRef) as PackedScene).instance() as Dialogue
	dlg.start(file, set, reset_state)
	get_tree().get_root().add_child(dlg)
	return dlg
	
	
func flashback(file: String, art: Texture) -> Flashback:
	var fb: PackedScene = load(FlashbackRef) as PackedScene
	var fb_i = fb.instance() as Flashback
	fb_i.set_fb_file(file)
	fb_i.set_art(art)
	get_tree().get_root().add_child(fb_i)
	fb_i.start()
	return fb_i


func start_discourse(file: String, right_name: String, right_sprite: SpriteFrames, left_name: String = "Cosmo", left_sprite: SpriteFrames = (load(CosmoSprite) as SpriteFrames)):
	Player.set_state(Player.PlayerState.NoInput)
	
	d_previous_scene = get_tree().get_root().get_node("Scene").get_filename()
	d_previous_pos = Player.get_position()
	d_previous_dir = Player.get_direction()
	
	var start := (load(DiscourseStartRef) as PackedScene).instance()
	start.set_position(Vector2.ZERO)
	get_tree().get_root().add_child(start)
	yield(get_tree().create_timer(4.5), "timeout")
	draw_overlay(false)
	draw_overlay_map(false)
	goto_scene(DiscourseScene, Vector2.ZERO, Player.Direction.Down, false)
	yield(get_tree().create_timer(0.02), "timeout")
	Player.hide()
	get_tree().get_root().get_node("Scene").run_discourse(file, right_name, right_sprite, left_name, left_sprite)
	
	
func draw_overlay(draw: bool):
	$Overlay/CanvasLayer/Sprite.set_visible(draw)
	$Overlay/CanvasLayer/Money.set_visible(draw)


func draw_overlay_map(draw: bool):
	$Overlay/CanvasLayer/Map.set_visible(draw)

# =====================================================================

func goto_scene_post(pos: Vector2, direction: int):
	yield(get_tree(), "idle_frame")
	var p := Player
	p.set_position(pos)
	p.set_direction(direction)
	
# =====================================================================

func controller_connection(device: int, connected: bool):
	controller_connected = connected
	if connected:
		print(Input.get_joy_name(0))
