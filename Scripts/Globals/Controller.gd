extends Node

#class_name Controller

signal scene_changed
signal fullscreen_toggled(fullscreen)
signal windowsize_changed(size)

const DialogueRef := "res://Instances/Dialogue.tscn"
const DiscourseStartRef := "res://Scenes/DiscourseStart.tscn"
const CosmoSprite := "res://Resources/Sprite Frames/SpriteFrames_Cosmo.tres"
const DiscourseScene := "res://Scenes/Discourse.tscn"
const MenuRef := "res://Instances/System/Menu.tscn"
const SaveMenuRef := "res://Instances/System/MenuSave.tscn"
const OptionsMenuRef := "res://Instances/System/MenuOptions.tscn"
const ExitMenuRef := "res://Instances/System/MenuExit.tscn"
const FlashbackRef := "res://Instances/System/Flashback.tscn"

const SoundOneShotRef := preload("res://Instances/SoundOneShot.tscn")
const ItemRef := preload("res://Instances/System/Item.tscn")
const EmoteRef := preload("res://Instances/System/Emote.tscn")

enum Emote {Exclamation, Question, Interrobang}

#var inventory := []

var flags: Dictionary = {
	# ========================================
	# SCENES
	# ========================================
	"scn_intro": 0,
	"scn_rhona": 0,
	"scn_lm_intro": 0,
	"scn_ainsley's_intro": 0,
	# ========================================
	# NPCS
	# ========================================
	"npc_train_rudeman": 0,
	"npc_train_unsurewoman": 0,
	"npc_train_rhona": 0,
	# ----------------------------------------
	"npc_lm_guide": 0,
	"npc_lm_pace": 0,
	"npc_lm_keifer": 0,
	"npc_lm_ariad": 0,
	"npc_ainsleys_paul": 0,
	"npc_ainsleys_rhona": 0,
	"npc_ainsleys_computer": 0,
	# ----------------------------------------
	"npc_motel_chip": 0,
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
	"volume": 7,
	"window_size": 0, # 0 = 1x, 1 = 2x, 2 = 3x
	"fullscreen": 0, # 0 = No, 1 = Yes
	"text_speed_overworld": 1, # 0 = Slow, 1 = Medium, 2 = Fast
	"text_speed_discourse": 2 # 0 = Slow, 1 = Medium, 2 = Fast
}

const map_marker_locs: Dictionary = {
	"res://Scenes/Los Muertos/LM_Trainstation.tscn":    Vector2(3, 4),
	"res://Scenes/Los Muertos/LM_Trainstation_L.tscn":  Vector2(2, 4),
	"res://Scenes/Los Muertos/LM_Trainstation_R1.tscn": Vector2(4, 4),
	"res://Scenes/Los Muertos/LM_Trainstation_R2.tscn": Vector2(5, 4),
	"res://Scenes/Los Muertos/LM_Crossroads.tscn":      Vector2(3, 3),
	"res://Scenes/Los Muertos/LM_Waterfront_R1.tscn":   Vector2(4, 3),
	"res://Scenes/Los Muertos/LM_Waterfront_R2.tscn":   Vector2(5, 3),
	"res://Scenes/Los Muertos/LM_Waterfront_L1.tscn":   Vector2(2, 3),
	"res://Scenes/Los Muertos/LM_Mainstreet_S.tscn":    Vector2(3, 2),
	"res://Scenes/Los Muertos/LM_Mainstreet_N.tscn":    Vector2(3, 1),
	"res://Scenes/Los Muertos/LM_Square.tscn":          Vector2(3, 0),
	"res://Scenes/Los Muertos/LM_Square_R.tscn":        Vector2(4, 0),
	"res://Scenes/Los Muertos/LM_Mainstreet_R.tscn":    Vector2(4, 1),
	"res://Scenes/Los Muertos/LM_Eastside_N.tscn":      Vector2(5, 1),
	"res://Scenes/Los Muertos/LM_Eastside_S.tscn":      Vector2(5, 2),
	"res://Scenes/Los Muertos/LM_Conduit.tscn":         Vector2(5, 0),
	"res://Scenes/Los Muertos/LM_Thoroughfare_R.tscn":  Vector2(2, 1),
	"res://Scenes/Los Muertos/LM_Thoroughfare_M.tscn":  Vector2(1, 1),
	"res://Scenes/Los Muertos/LM_Thoroughfare_L.tscn":  Vector2(0, 1),
	"res://Scenes/Los Muertos/LM_Topstreet_L.tscn":     Vector2(0, 0),
	"res://Scenes/Los Muertos/LM_Topstreet_M.tscn":     Vector2(1, 0),
	"res://Scenes/Los Muertos/LM_Topstreet_R.tscn":     Vector2(2, 0),
	"res://Scenes/Los Muertos/LM_Westside.tscn":        Vector2(0, 2),
	"res://Scenes/Los Muertos/LM_Waterfront_L2.tscn":   Vector2(1, 3),
	"res://Scenes/Los Muertos/LM_Waterfront_L3.tscn":   Vector2(0, 3)
}

var playtime: float = 0.0
var track_playtime := false

var money: int = 20
var money_disp: int = 20

var text_speed_ow: int = 1
var text_speed_d: int = 2

var menu_open := false

var d_previous_scene: String
var d_previous_pos: Vector2
var d_previous_dir: int
var d_previous_npc: NodePath

var controller_connected: bool = false

onready var money_text := $Overlay/CanvasLayer/Money as Label
onready var anim_player := $AnimationPlayer as AnimationPlayer
onready var anim_player_fade := $AnimationPlayerFade as AnimationPlayer
onready var map_marker := $Overlay/CanvasLayer/Map/Marker as Sprite

# =====================================================================

func _ready():
	randomize()
	
	controller_connected = len(Input.get_connected_joypads()) > 0
	Input.connect("joy_connection_changed", self, "controller_connection")
	
	var f := File.new()
	var fname := "user://config.uf"
	if f.file_exists(fname):
		f.open(fname, File.READ)
		var data: Dictionary = parse_json(f.get_line())
		
		update_settings(int(data["volume"]), int(data["window_size"]), int(data["fullscreen"]), int(data["text_speed_overworld"]), int(data["text_speed_discourse"]))
		
		if f.is_open():
			f.close()
		

func _process(delta: float):
	if track_playtime:
		playtime += delta
	
	if money_disp != money:
		money_disp = lerp(money_disp, money, 0.15)
	
	money_text.text = str(money_disp)
	
	if Input.is_action_just_pressed("sys_menu") and not menu_open and Player.get_state() != Player.PlayerState.NoInput:
		open_menu()
		
	if Input.is_action_just_pressed("sys_fullscreen"):
		OS.set_window_fullscreen(not OS.is_window_fullscreen())
		settings["fullscreen"] = 1 if OS.is_window_fullscreen() else 0
		save_settings()
		emit_signal("fullscreen_toggled", OS.is_window_fullscreen())
		
	if Input.is_action_just_pressed("sys_windowsize"):
		match int(settings["window_size"]):
			0:
				OS.set_window_size(Vector2(1920, 1080))
				settings["window_size"] = 1
			1:
				OS.set_window_size(Vector2(2560, 1440))
				settings["window_size"] = 2
			2:
				OS.set_window_size(Vector2(1280, 720))
				settings["window_size"] = 0
		OS.center_window()
		save_settings()
		emit_signal("windowsize_changed", int(settings["window_size"]))
				
		
	#if Input.is_action_just_pressed("debug_2"):
	#	save_game(0, OS.get_datetime())

# =====================================================================

func flag(key: String) -> int:
	return flags[key]
	

func set_flag(key: String, value: int):
	flags[key] = value
	
	
func get_playtime() -> float:
	return playtime
	

func set_playtime(value: float):
	playtime = value
	
	
func get_playtime_str(playtime_value: float) -> String:
	return str(floor(playtime_value / 3600)).pad_zeros(2) + ":" + str(floor(playtime_value / 60)).pad_zeros(2) + ":" + str(int(floor(playtime_value)) % 60).pad_zeros(2)

	
func set_tracking_playtime(value: bool):
	track_playtime = value
	
	
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
	
	
func update_settings(volume: int, window_size: int, fullscreen: int, text_speed_overworld: int, text_speed_discourse: int):
	# Volume
	AudioServer.set_bus_volume_db(0, -80 + 80 * (volume / 10.0))
	settings["volume"] = volume
	
	# Fullscreen
	OS.set_window_fullscreen(fullscreen == 1)
	settings["fullscreen"] = fullscreen
	
	# Window size
	match window_size:
		0:
			OS.set_window_size(Vector2(1280, 720))
		1:
			OS.set_window_size(Vector2(1920, 1080))
		2:
			OS.set_window_size(Vector2(2560, 1440))
	OS.center_window()
	settings["window_size"] = window_size
	
	# Text speed
	text_speed_ow = text_speed_overworld
	settings["text_speed_overworld"] = text_speed_overworld
	text_speed_d = text_speed_discourse
	settings["text_speed_discourse"] = text_speed_discourse
	
	
func save_settings():
	var f := File.new()
	var fname := "user://config.uf"
	if f.file_exists(fname):
		var dir := Directory.new()
		dir.remove(fname)
		
	f.open(fname, File.WRITE)
	f.store_line(to_json(settings))
	
	if f.is_open():
		f.close()	

	
func post_discourse():
	Player.set_state(Player.PlayerState.Move)
	(get_node(d_previous_npc) as EventNPC).show_interact(true)
	
	
func show_emote(type: int, target: Node2D, offset: Vector2 = Vector2(0, -16)):
	var e: Node2D = EmoteRef.instance() as Node2D
	e.set_position(target.get_position() + offset)
	match type:
		Emote.Exclamation:
			(e.get_node("AnimationPlayer") as AnimationPlayer).play("Exclamation")
		Emote.Question:
			(e.get_node("AnimationPlayer") as AnimationPlayer).play("Question")
	get_tree().get_root().add_child(e)
	
	
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
	
	
func enable_dark_hour(enable: bool):
	$CanvasLayerTint/Tint.set_visible(enable)
	
	
func select_menu_button(buttons: Array, index: String, destroy: bool = true):
	for but in buttons:
		if but.get_name() == index:
			but.anim_selected(destroy)
		else:
			but.anim_not_selected(destroy)
	
	
func open_menu():
	menu_open = true
	Player.set_state(Player.PlayerState.NoInput)
	var menu := (load(MenuRef) as PackedScene).instance()
	get_tree().get_root().add_child(menu)	
	
	
func open_save_menu(load_: bool, use_background: bool = true):
	var menu := (load(SaveMenuRef) as PackedScene).instance()
	menu.set_load_mode(load_)
	get_tree().get_root().add_child(menu)
	menu.start(use_background)
	return menu
	
	
func open_options_menu(use_background: bool = true):
	var menu := (load(OptionsMenuRef) as PackedScene).instance()
	get_tree().get_root().add_child(menu)
	menu.start(use_background)
	return menu


func open_exit_menu(parent_menu):
	var menu := (load(ExitMenuRef) as PackedScene).instance()
	menu.set_parent_menu(parent_menu)
	get_tree().get_root().add_child(menu)
	return menu


func goto_scene(path: String, pos: Vector2, direction: int, transition: bool, relative_coords: bool = true):
	if transition:
		Player.set_state(Player.PlayerState.NoInput)
		Player.set_in_transition(true)
		var current_scene := get_tree().get_root().get_node("Scene")
		var scn: PackedScene = load(path) as PackedScene
		var scn_i := scn.instance() as Node2D
		
		# Setup player movement
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
		
		# Move map marker
		update_map_marker(path)
		
		# Scroll camera
		anim_player.get_animation("CameraScroll").track_set_key_value(0, 1, target)
		anim_player.play("CameraScroll")
		Player.scroll_offset(player_offset)
		yield(anim_player, "animation_finished")
		
		# Swap the active scene
		current_scene.set_name("__temp")
		scn_i.set_name("Scene")
		current_scene.queue_free()
		
		# Cover up the position discrepancies
		Player.position -= target
		scn_i.set_position(Vector2.ZERO)
		$MainCamera.set_offset(Vector2.ZERO)
		
		Player.set_in_transition(false)
		Player.set_state(Player.PlayerState.Move)
		emit_signal("scene_changed")
	else:
		var current_scene := get_tree().get_root().get_node("Scene")
		var scn: PackedScene = load(path) as PackedScene
		var scn_i := scn.instance()
		get_tree().get_root().add_child(scn_i)
		update_map_marker(path)
		Player.set_position(pos)
		Player.set_direction(direction)
		
		current_scene.set_name("__temp")
		scn_i.set_name("Scene")
		current_scene.queue_free()
		emit_signal("scene_changed")
		
		
func update_map_marker(path: String):
	var loc: Vector2 = map_marker_locs.get(path)
	if loc != null:
		map_marker.set_position(Vector2(4 + 8 * loc.x, 3 + 6 * loc.y))
		map_marker.show()
	else:
		map_marker.hide()
		
		
func save_game(slot: int, datetime: Dictionary):
	var f := File.new()
	var fname := "user://data_s" + str(slot + 1) + ".uf"
	if f.file_exists(fname):
		var dir := Directory.new()
		dir.remove(fname)
		
	f.open_encrypted_with_pass(fname, File.WRITE, OS.get_unique_id())
	var save_info: Dictionary = {}
	
	save_info["datetime"] = to_json(datetime)
	save_info["playtime"] = playtime
	save_info["current_scene"] = get_node("/root/Scene").get_filename()
	save_info["player_x"] = Player.get_position().x
	save_info["player_y"] = Player.get_position().y
	save_info["player_dir"] = Player.get_direction()
	save_info["money"] = money
	save_info["flags"] = to_json(flags)
	
	f.store_line(to_json(save_info))
	
	if f.is_open():
		f.close()


func load_game(slot: int):
	var f := File.new()
	var fname := "user://data_s" + str(slot + 1) + ".uf"
	assert(f.file_exists(fname))
	f.open_encrypted_with_pass(fname, File.READ, OS.get_unique_id())
	var load_info: Dictionary = parse_json(f.get_line())
	
	var scn: String = load_info["current_scene"]
	var pos: Vector2 = Vector2(load_info["player_x"], load_info["player_y"])
	var dir: int = load_info["player_dir"]
	money = load_info["money"]
	flags = parse_json(load_info["flags"])
	playtime = load_info["playtime"]
	
	if f.is_open():
		f.close()

	goto_scene(scn, pos, dir, false)
	update_map_marker(scn)
	draw_overlay(true)
	draw_overlay_map(true)
	Player.show()
	Controller.set_tracking_playtime(true)


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
	
	
func dialogue(file: String, set: int, alt_box_type: bool = false, text_size: int = 8, reset_state: bool = true) -> Dialogue:
	var dlg: Dialogue = (load(DialogueRef) as PackedScene).instance() as Dialogue
	dlg.set_text_size(text_size)
	dlg.set_text_speed(text_speed_ow)
	if alt_box_type:
		dlg.set_alt_box_texture()
	dlg.start(file, set, reset_state)
	get_tree().get_root().add_child(dlg)
	return dlg
	
	
func flashback(file: String, art: Texture, transition: bool = true, anim_player_: AnimationPlayer = null) -> Flashback:
	var fb: PackedScene = load(FlashbackRef) as PackedScene
	var fb_i = fb.instance() as Flashback
	fb_i.set_fb_file(file)
	fb_i.set_art(art)
	get_tree().get_root().add_child(fb_i)
	fb_i.start(transition, anim_player_)
	return fb_i


func start_discourse(full_name: String, file: String, right_name: String, right_sprite: SpriteFrames, left_name: String = "Cosmo", left_sprite: SpriteFrames = (load(CosmoSprite) as SpriteFrames)):
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
	get_tree().get_root().get_node("Scene").run_discourse(full_name, file, right_name, right_sprite, left_name, left_sprite, text_speed_d)
	
	
func draw_overlay(draw: bool):
	$Overlay/CanvasLayer/Sprite.set_visible(draw)
	$Overlay/CanvasLayer/Money.set_visible(draw)


func draw_overlay_map(draw: bool):
	$Overlay/CanvasLayer/Map.set_visible(draw)
	
	
func get_month_str(month: int, short: bool = true) -> String:
	match month:
		1:
			return "Jan" if short else "January"
		2:
			return "Feb" if short else "February"
		3:
			return "Mar" if short else "March"
		4:
			return "Apr" if short else "April"
		5:
			return "May"
		6:
			return "Jun" if short else "June"
		7:
			return "Jul" if short else "July"
		8:
			return "Aug" if short else "August"
		9:
			return "Sep" if short else "September"
		10:
			return "Oct" if short else "October"
		11:
			return "Nov" if short else "November"
		12:
			return "Dec" if short else "December"

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
