extends Node2D

class_name DiscourseController

signal choice_clicked
signal ignore_line

const XLower = 55
const XUpper = 285
const YLower = 15
const YUpper = 140

const line_regex_p := "^(\\S+)\\s+(.+)$"
const buttons_regex_p := "^\\s*([^\\r\\n\\t\\f\\v]+)\\s\\(([\\d-]+),\\s*([\\d-]+)\\)\\s*\\[(\\d+),\\s*(\\d+)\\]\\s*$"
const choices_regex_p := "^(\\d+) (.+)$"
const flag_regex_p := "^(.+)\\s+(\\d+)$"

var line_regex := RegEx.new()
var buttons_regex := RegEx.new()
var choices_regex := RegEx.new()
var flag_regex := RegEx.new()

var co_target = null
var co_signal: String = ""

const ChoiceButton := preload("res://Instances/ChoiceButton.tscn")
const CosmoSprite := preload("res://Resources/Sprite Frames/SpriteFrames_Cosmo.tres")
const DiscourseCharacterRef := preload("res://Instances/DiscourseCharacter.tscn")

var script_list := []
var buttons_list := []

var character_left: DiscourseCharacter = null
var character_right: DiscourseCharacter = null
var name_left: String = ""
var name_right: String = ""
var speaker_right := false

var list_index: int = 0
var response := false
var response_end: int = -1
var response_end_total: int = -1

onready var text_controller := $TextDisplay

func _ready():
	randomize()
	
	line_regex.compile(line_regex_p)
	buttons_regex.compile(buttons_regex_p)
	choices_regex.compile(choices_regex_p)
	flag_regex.compile(flag_regex_p)

# =====================================================================

func run_discourse(file: String, right_name: String, right_sprite: SpriteFrames, left_name: String = "Cosmo", left_sprite: SpriteFrames = CosmoSprite):
	var cl := DiscourseCharacterRef.instance()
	cl.set_spriteframes(left_sprite)
	get_tree().get_root().add_child(cl)
	character_left = cl
	
	var cr = DiscourseCharacterRef.instance()
	cr.set_spriteframes(right_sprite)
	get_tree().get_root().add_child(cr)
	cr.position.x += 152
	character_right = cr
	
	name_left = left_name
	name_right = right_name
	
	load_file(file)
	
	character_left.hide()
	character_right.hide()
	
	$AnimationPlayerLeftChar.get_animation("Movein").add_track(Animation.TYPE_VALUE, 0)
	$AnimationPlayerLeftChar.get_animation("Movein").track_set_path(0, NodePath(str(character_left.get_path()) + ":position"))
	$AnimationPlayerLeftChar.get_animation("Movein").track_set_interpolation_type(0, Animation.INTERPOLATION_CUBIC)
	$AnimationPlayerLeftChar.get_animation("Movein").track_insert_key(0, 0, character_left.get_position() - Vector2(200, 0), 0.4)
	$AnimationPlayerLeftChar.get_animation("Movein").track_insert_key(0, 1, character_left.get_position())
	$AnimationPlayerLeftChar.get_animation("Movein").add_track(Animation.TYPE_VALUE, 1)
	$AnimationPlayerLeftChar.get_animation("Movein").track_set_path(1, NodePath(str(character_left.get_path()) + ":visible"))
	$AnimationPlayerLeftChar.get_animation("Movein").track_insert_key(1, 0, true)
	
	$AnimationPlayerRightChar.get_animation("Movein").add_track(Animation.TYPE_VALUE, 0)
	$AnimationPlayerRightChar.get_animation("Movein").track_set_path(0, NodePath(str(character_right.get_path()) + ":position"))
	$AnimationPlayerRightChar.get_animation("Movein").track_set_interpolation_type(0, Animation.INTERPOLATION_CUBIC)
	$AnimationPlayerRightChar.get_animation("Movein").track_insert_key(0, 0, character_right.get_position() + Vector2(200, 0), 0.4)
	$AnimationPlayerRightChar.get_animation("Movein").track_insert_key(0, 0.25, character_right.get_position() + Vector2(200, 0), 0.4)
	$AnimationPlayerRightChar.get_animation("Movein").track_insert_key(0, 1.25, character_right.get_position())
	$AnimationPlayerRightChar.get_animation("Movein").add_track(Animation.TYPE_VALUE, 1)
	$AnimationPlayerRightChar.get_animation("Movein").track_set_path(1, NodePath(str(character_right.get_path()) + ":visible"))
	$AnimationPlayerRightChar.get_animation("Movein").track_insert_key(1, 0, true)
	
	yield(get_tree().create_timer(1.0), "timeout")
	
	$AnimationPlayerLeftChar.play("Movein")
	$AnimationPlayerRightChar.play("Movein")
	
	yield(get_tree().create_timer(2.5), "timeout")
	
	list_index = 0
	while list_index < len(script_list):
		parse_discourse_command(script_list[list_index])
		yield(co_target, co_signal)
		
		if response and list_index == response_end:
			list_index = response_end_total
			response = false
		else:
			list_index += 1
			
	text_controller.hide()
	$AnimationPlayer.play("Fadeout")
			

func click_choice(index: int):
	var i: int = 0
	for but in buttons_list:
		if i == index:
			response = true
			list_index = but.get_target_line_start() - 2
			response_end = but.get_target_line_end() - 1
			but.anim_selected()
		else:
			but.anim_not_selected()
		
		i += 1
		
	buttons_list.clear()

# =====================================================================

func create_button(text: String, pos: Vector2, index: int, start_line: int, end_line: int):
	var but := ChoiceButton.instance()
	but.set_text_controller($TextDisplay)
	but.set_controller(self)
	but.set_index(index)
	but.set_target_lines(start_line, end_line)
	but.set_position(Vector2(160, 90))
	but.set_button_text(text)
	but.setup_animation(pos)
	buttons_list.push_back(but)
	but.connect("clicked", self, "emit_signal", ["choice_clicked"])
	yield(get_tree().create_timer(0.02), "timeout")
	get_tree().get_root().add_child(but)


func load_file(path: String):
	var file := File.new()
	file.open(path, File.READ)
	while not file.eof_reached():
		script_list.push_back(file.get_line())
	if file.is_open():
		file.close()


func parse_discourse_command(command: String):
	var result = line_regex.search(command)
	if result != null:
		var text = result.get_string(2)
		match line_regex.search(command).get_string(1):
			"<":
				text_controller.set_name_text(name_left)
				text_controller.set_name_side(false)
				text_controller.show_box()
				speaker_right = false
				co_target = text_controller
				co_signal = "text_ended_button"
				text_controller.display_text(text)
			">":
				text_controller.set_name_text(name_right)
				text_controller.set_name_side(true)
				text_controller.show_box()
				speaker_right = true
				co_target = text_controller
				co_signal = "text_ended_button"
				text_controller.display_text(text)
			"<<":
				text_controller.set_name_text(name_left)
				text_controller.set_name_side(false)
				text_controller.show_box()
				speaker_right = false
				co_target = text_controller
				co_signal = "text_ended"
				text_controller.set_header_text(text)
				text_controller.display_text(text)
			">>":
				text_controller.set_name_text(name_right)
				text_controller.set_name_side(true)
				text_controller.show_box()
				speaker_right = true
				co_target = text_controller
				co_signal = "text_ended"
				text_controller.set_header_text(text)
				text_controller.display_text(text)
			"|":
				text_controller.hide_box()
				co_target = get_tree().create_timer(float(text))
				co_signal = "timeout"
			"@<":
				co_target = self
				co_signal = "ignore_line"
				character_left.set_sprite(text)
				yield(get_tree().create_timer(0.02), "timeout")
				emit_signal("ignore_line")
			"@>":
				co_target = self
				co_signal = "ignore_line"
				character_right.set_sprite(text)
				yield(get_tree().create_timer(0.02), "timeout")
				emit_signal("ignore_line")
			"[":
				co_target = self
				co_signal = "choice_clicked"
				response_end_total = int(choices_regex.search(text).get_string(1)) - 1
				var buttons: PoolStringArray = choices_regex.search(text).get_string(2).split("|")
				text_controller.fade_screen(true)
				var i: int = 0
				for but in buttons:
					create_button(buttons_regex.search(but).get_string(1), Vector2(160 + int(buttons_regex.search(but).get_string(2)), 90 + int(buttons_regex.search(but).get_string(3))), i, int(buttons_regex.search(but).get_string(4)), int(buttons_regex.search(but).get_string(5)))
					i += 1
			"*":
				Controller.set_flag(flag_regex.search(text).get_string(1), int(flag_regex.search(text).get_string(2)))
				co_target = self
				co_signal = "ignore_line"
				yield(get_tree().create_timer(0.02), "timeout")
				emit_signal("ignore_line")
			_:
				co_target = self
				co_signal = "ignore_line"
				yield(get_tree().create_timer(0.02), "timeout")
				emit_signal("ignore_line")
	else:
		co_target = self
		co_signal = "ignore_line"
		yield(get_tree().create_timer(0.02), "timeout")
		emit_signal("ignore_line")
