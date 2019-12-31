extends Node2D

class_name DiscourseController

signal choice_clicked
signal ignore_line

const line_regex_p := "^(\\S+)\\s+(.+)$" # ^(\S+)\s+(.+)$
const buttons_regex_p := "^\\s*([^\\r\\n\\t\\f\\v]+)\\s\\(([\\d-]+),\\s*([\\d-]+)\\)\\s*(\\w+)\\s*$" # ^\s*([^\r\n\t\f\v]+)\s\(([\d-]+),\s*([\d-]+)\)\s*(\w+)\s*$
const flag_regex_p := "^(.+)\\s+(\\d+)$" # ^(.+)\s+(\d+)$
const flag_regex_2_p := "^(.+)\\s+(\\d+)\\s+(\\w+)$" # ^(.+)\s+(\d+)\s+(\w+)$

var line_regex := RegEx.new()
var buttons_regex := RegEx.new()
var flag_regex := RegEx.new()
var flag_regex_2 := RegEx.new()

var co_target = null
var co_signal: String = ""

const ChoiceButton := preload("res://Instances/System/Button.tscn")
const CosmoSprite := preload("res://Resources/Sprite Frames/SpriteFrames_Cosmo.tres")
const DiscourseCharacterRef := preload("res://Instances/DiscourseCharacter.tscn")

var script_list := []
var buttons_list := []
var label_table := {}

var character_left: DiscourseCharacter = null
var character_right: DiscourseCharacter = null
var name_left: String = ""
var name_right: String = ""
var speaker_right := false

var list_index: int = 0

onready var text_controller := $TextDisplay as TextDisplay
onready var anim_player_left := $AnimationPlayerLeftChar as AnimationPlayer
onready var anim_player_right := $AnimationPlayerRightChar as AnimationPlayer

# =====================================================================

func _ready():
	line_regex.compile(line_regex_p)
	buttons_regex.compile(buttons_regex_p)
	flag_regex.compile(flag_regex_p)
	flag_regex_2.compile(flag_regex_2_p)

# =====================================================================

func run_discourse(full_name: String, file: String, right_name: String, right_sprite: SpriteFrames, left_name: String = "Cosmo", left_sprite: SpriteFrames = CosmoSprite):
	$Name/Label.set_text(full_name)
	
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
	
	anim_player_left.get_animation("Movein").add_track(Animation.TYPE_VALUE, 0)
	anim_player_left.get_animation("Movein").track_set_path(0, NodePath(str(character_left.get_path()) + ":position"))
	anim_player_left.get_animation("Movein").track_set_interpolation_type(0, Animation.INTERPOLATION_CUBIC)
	anim_player_left.get_animation("Movein").track_insert_key(0, 0, character_left.get_position() - Vector2(200, 0), 0.4)
	anim_player_left.get_animation("Movein").track_insert_key(0, 1, character_left.get_position())
	anim_player_left.get_animation("Movein").add_track(Animation.TYPE_VALUE, 1)
	anim_player_left.get_animation("Movein").track_set_path(1, NodePath(str(character_left.get_path()) + ":visible"))
	anim_player_left.get_animation("Movein").track_insert_key(1, 0, true)
	
	anim_player_right.get_animation("Movein").add_track(Animation.TYPE_VALUE, 0)
	anim_player_right.get_animation("Movein").track_set_path(0, NodePath(str(character_right.get_path()) + ":position"))
	anim_player_right.get_animation("Movein").track_set_interpolation_type(0, Animation.INTERPOLATION_CUBIC)
	anim_player_right.get_animation("Movein").track_insert_key(0, 0, character_right.get_position() + Vector2(200, 0), 0.4)
	anim_player_right.get_animation("Movein").track_insert_key(0, 0.25, character_right.get_position() + Vector2(200, 0), 0.4)
	anim_player_right.get_animation("Movein").track_insert_key(0, 1.25, character_right.get_position())
	anim_player_right.get_animation("Movein").add_track(Animation.TYPE_VALUE, 1)
	anim_player_right.get_animation("Movein").track_set_path(1, NodePath(str(character_right.get_path()) + ":visible"))
	anim_player_right.get_animation("Movein").track_insert_key(1, 0, true)
	
	yield(get_tree().create_timer(1.0), "timeout")
	
	anim_player_left.play("Movein")
	anim_player_right.play("Movein")
	
	yield(get_tree().create_timer(2.5), "timeout")
	
	list_index = 0
	while list_index < len(script_list):
		parse_discourse_command(script_list[list_index])
		yield(co_target, co_signal)
		list_index += 1
			
	text_controller.hide()
	$AnimationPlayer.play("Fadeout")
	yield($AnimationPlayer, "animation_finished")
	Controller.fade(0.05, true, Color(1, 1, 1))
	yield(get_tree().create_timer(0.5), "timeout")
	
	character_left.queue_free()
	character_right.queue_free()
	Controller.draw_overlay(true)
	Player.show()
	Controller.goto_scene(Controller.get_previous_scene(), Controller.get_previous_pos(), Controller.get_previous_dir(), false, false)
	yield(get_tree(), "tree_changed")

	(get_node(Controller.get_previous_npc()) as EventNPC).increment_dialogue_set()
	(get_tree().create_timer(0.05)).connect("timeout", get_node(Controller.get_previous_npc()) as EventNPC, "show_interact", [false])
	Controller.fade(1.0, false, Color(1, 1, 1), true)
	(get_tree().create_timer(1.0)).connect("timeout", Controller, "post_discourse")
			

func click_choice(index: int):
	var i: int = 0
	for but in buttons_list:
		if i == index:
			list_index = but.get_target_line()
			but.anim_selected()
		else:
			but.anim_not_selected()
		
		i += 1
		
	buttons_list.clear()

# =====================================================================

func create_button(text: String, pos: Vector2, index: int, target_line: int) -> ButtonUF:
	var but := ChoiceButton.instance() as ButtonUF
	but.set_text_controller($TextDisplay)
	but.set_controller(self)
	but.set_index(index)
	but.set_target_line(target_line)
	but.set_position(pos)
	buttons_list.push_back(but)
	but.connect("clicked", text_controller, "trigger_buffer")
	but.connect("clicked", self, "emit_signal", ["choice_clicked"])
	yield(get_tree().create_timer(0.02), "timeout")
	get_tree().get_root().add_child(but)
	but.set_button_text(text)
	but.appear()
	return but


func load_file(path: String):
	var file := File.new()
	file.open(path, File.READ)
	while not file.eof_reached():
		var line: String = file.get_line()
		script_list.push_back(line)
		
		# If this is a label, add it to the lookup table
		if line[0] == ":":
			label_table[line.substr(2, len(line) - 2)] = len(script_list) - 1
			
	if file.is_open():
		file.close()


func parse_discourse_command(command: String):
	var result := line_regex.search(command)
	if result != null:
		var text = result.get_string(2)
		match line_regex.search(command).get_string(1):
			"<": # Dialogue left - FORMAT: < `Text`
				text_controller.set_name_text(name_left)
				text_controller.set_name_side(false)
				text_controller.set_name_visible(true)
				text_controller.show_box(TextDisplay.BoxType.Left)
				speaker_right = false
				co_target = text_controller
				co_signal = "text_ended_button"
				text_controller.display_text(text)
				
			">": # Dialogue right - FORMAT: > `Text`
				text_controller.set_name_text(name_right)
				text_controller.set_name_side(true)
				text_controller.set_name_visible(true)
				text_controller.show_box(TextDisplay.BoxType.Right)
				speaker_right = true
				co_target = text_controller
				co_signal = "text_ended_button"
				text_controller.display_text(text)
				
			"<<": # Dialogue left hold - FORMAT: << `Text`
				text_controller.set_name_text(name_left)
				text_controller.set_name_side(false)
				text_controller.set_name_visible(true)
				text_controller.show_box(TextDisplay.BoxType.Left)
				speaker_right = false
				co_target = text_controller
				co_signal = "text_ended"
				text_controller.set_header_text(text)
				text_controller.display_text(text)
				
			">>": # Dialogue right hold - FORMAT: >> `Text`
				text_controller.set_name_text(name_right)
				text_controller.set_name_side(true)
				text_controller.set_name_visible(true)
				text_controller.show_box(TextDisplay.BoxType.Right)
				speaker_right = true
				co_target = text_controller
				co_signal = "text_ended"
				text_controller.set_header_text(text)
				text_controller.display_text(text)
				
			"|": # Pause - FORMAT: | `Time in sec`
				text_controller.hide_box()
				co_target = get_tree().create_timer(float(text))
				co_signal = "timeout"
				
			"@<": # Change sprite left - FORMAT: @< `Animation name`
				co_target = self
				co_signal = "ignore_line"
				character_left.set_sprite(text)
				yield(get_tree().create_timer(0.02), "timeout")
				emit_signal("ignore_line")
				
			"@>": # Change sprite right - FORMAT: @> `Animation name`
				co_target = self
				co_signal = "ignore_line"
				character_right.set_sprite(text)
				yield(get_tree().create_timer(0.02), "timeout")
				emit_signal("ignore_line")
				
			"[": # Choice - FORMAT: [ `Choice text` (`x coord of choice`, `y coord of choice`) `LABEL_AT_START_OF_BRANCH` | for each choice
				co_target = self
				co_signal = "choice_clicked"
				var buttons: PoolStringArray = text.split("|")
				text_controller.fade_screen(true)
				var i: int = 0
				for but in buttons:
					create_button(buttons_regex.search(but).get_string(1), Vector2(160 + int(buttons_regex.search(but).get_string(2)), 90 + int(buttons_regex.search(but).get_string(3))), i, label_table[buttons_regex.search(but).get_string(4)])
					i += 1
				
				# Link buttons together in Control focus
				for n in range(3):
					(buttons_list[n] as ButtonUF).set_neighbor_previous(buttons_list[wrapi(n - 1, 0, len(buttons_list) - 1)] as ButtonUF)
					(buttons_list[n] as ButtonUF).set_neighbor_next(buttons_list[wrapi(n + 1, 0, len(buttons_list) - 1)] as ButtonUF)

			"^": # Jump to label - FORMAT: ^ `LABEL_NAME`
				list_index = label_table[text]
				co_target = self
				co_signal = "ignore_line"
				yield(get_tree().create_timer(0.02), "timeout")
				emit_signal("ignore_line")
				
			"*": # Set flag - FORMAT: * `Flag` `Value`
				Controller.set_flag(flag_regex.search(text).get_string(1), int(flag_regex.search(text).get_string(2)))
				co_target = self
				co_signal = "ignore_line"
				yield(get_tree().create_timer(0.02), "timeout")
				emit_signal("ignore_line")
				
			"?": # Jump to label if flag is set - FORMAT: ? `Flag` `Value` `TARGET_LABEL`
				if Controller.flag(flag_regex_2.search(text).get_string(1)) == int(flag_regex_2.search(text).get_string(2)):
					list_index = label_table[flag_regex_2.search(text).get_string(3)]
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
