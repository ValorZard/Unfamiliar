extends Node2D

export(AudioStream) var sound_type

class_name Dialogue

signal dialogue_ended
signal text_roll_ended
signal dialogue_ended_jump(jump_point)

const ButtonRef := preload("res://Instances/System/ButtonOverworldChoice.tscn")

const name_regex_pat := "^(.+:).+$"
const choice_regex_pat := "^\\s*(\\w+)\\((\\w+)\\)\\s*$"
const choice_regex_2_pat := "^]\\s*(.+) >\\s*(.+)\\s*$"
const flag_regex_pat := "^\\s*(\\w+)\\s+(\\d+)\\s*$"
const conditional_regex_pat := "^\\s*(\\w+)\\s+(\\d+)\\s+(\\w+)\\s*$"

const name_bbcode_start := "[color=#7ca3ff]"
const name_bbcode_end := "[/color]"

const ChoiceStartX := 106
const ChoiceStartY := 104
const ChoiceSep := 40

var text: PoolStringArray = []
var label_table := {}

var page: int = 0
var page_length: int = 0
var disp: int = 0
var roll := false

var current_name: String = ""

var text_size: int = 8

var allow_advance := false
var choice := false
var buffer := false
var buffer_choice := false

var buttons_list := []

var ended := false
var reset_state := true

var event_jump_point: float = NAN

var name_regex := RegEx.new()
var choice_regex := RegEx.new()
var choice_regex_2 := RegEx.new()
var flag_regex := RegEx.new()
var conditional_regex := RegEx.new()

onready var label := $Text as RichTextLabel

# =====================================================================

func _ready():
	$TimerRollText.start()


func _process(delta):
	label.set_visible_characters(disp)
	
	if Input.is_action_just_pressed("sys_select") and not buffer:
		if allow_advance and not choice:
			if page < len(text) - 1:
				advance_page()
			else:
				end()
			
			if not ended:
				start_roll()
		elif not choice and not buffer_choice:
			disp = len(text[page])
			buffer = true
			$TimerBuffer.start()
			
	if Input.is_action_just_pressed("debug_3"):
		page = len(text) - 1

# =====================================================================

func set_text_size(value: int):
	text_size = value


func set_alt_box_texture():
	$Box.hide()
	$Box2.show()


func set_text_speed(value: int):
	match value:
		0:
			$TimerRollText.set_wait_time(0.04)
		1:
			$TimerRollText.set_wait_time(0.03)
		2:
			$TimerRollText.set_wait_time(0.02)
	


func start(file: String, set: int, reset_state_: bool):
	# Compile regexes
	name_regex.compile(name_regex_pat)
	choice_regex.compile(choice_regex_pat)
	choice_regex_2.compile(choice_regex_2_pat)
	flag_regex.compile(flag_regex_pat)
	conditional_regex.compile(conditional_regex_pat)
	
	# Move box
	#if Player.get_position().y > 90:
	#	set_position(Vector2(86, 24))

	# Stop player
	Player.set_state(Player.PlayerState.NoInput)
	reset_state = reset_state_
	Player.stop_moving()
	
	# Load text
	load_text_from_file(file, set)
	page_length = len(text[page])
	insert_bbcode_tags()
	($Text as RichTextLabel).set_bbcode(text[page])
	get_node("Text").get("custom_fonts/normal_font").set_size(text_size)
	operation_handling()

# =====================================================================

func load_text_from_file(file: String, set: int):
	var f := File.new()
	f.open(file, File.READ)
	
	var read := false
	
	while not f.eof_reached():
		var line := f.get_line()
		if len(line) > 0 and line[0] == "-" and read:
			read = false
			break
		if read:
			text.push_back(line)
			
			# If this is a label, add it to the lookup table
			if line[0] == ":":
				label_table[line.substr(2, len(line) - 2)] = len(text) - 1
		if len(line) > 0 and line[0].is_valid_integer() and int(line) == set:
			read = true
	if f.is_open():
		f.close()


func insert_bbcode_tags():
	var mat := name_regex.search(text[page])
	if mat != null:
		if text[page][0] != "#":
			text[page] = text[page].insert(mat.get_end(1), name_bbcode_end)
			text[page] = text[page].insert(mat.get_start(1), name_bbcode_start)
			
			# Keep displaying current name if it's the same as the last page
#			var this_name: String = mat.get_string(1)
#			if current_name == this_name:
#				disp = len(this_name) + 1
#			else:
#				current_name = this_name
		else:
			text[page] = text[page].replace("#", "")


func advance_page():
	refresh_text()
	page += 1
	
	skip_labels()
	if ended:
		return

	operation_handling()


func show_choices():
	var template: String = choice_regex_2.search(text[page]).get_string(2)
	var buts: PoolStringArray = template.split("|")
	var index := 0
	for but in buts:
		var result := choice_regex.search(String(but))
		create_button(result.get_string(1), result.get_string(2), index)
		index += 1


func create_button(text_: String, target_label: String, index: int):
	var but := ButtonRef.instance() as ButtonUF
	but.set_position(Vector2(ChoiceStartX + ChoiceSep * index, ChoiceStartY))
	get_tree().get_root().add_child(but)
	buttons_list.push_back(but)
	yield(Controller.wait(0.02), "timeout")
	but.set_button_text(text_)
	but.connect("clicked", self, "goto_label", [target_label, index])
	but.connect("clicked", but, "anim_selected")
	but.appear()


func goto_label(label_name: String, button_index: int = -1):
	# Remove buttons if from choice
	if button_index >= 0:
		for i in range(len(buttons_list)):
			if i == button_index:
				(buttons_list[i] as ButtonUF).anim_selected()
			else:
				(buttons_list[i] as ButtonUF).anim_not_selected()
		
		buttons_list.clear()
	
	choice = false
	if is_connected("text_roll_ended", self, "show_choices"):
		disconnect("text_roll_ended", self, "show_choices")
		
	var target: int = label_table[label_name]
	if target < len(text) - 1:
		page = target
		advance_page()
		if not ended:
			start_roll()
	else:
		end()


func refresh_text():
	disp = 0
	($Text as RichTextLabel).set_visible_characters(disp)


func skip_labels():
	while page < len(text) and text[page][0] == ":":
		page += 1
		if page >= len(text):
			end()


func operation_handling():
	match text[page][0]:
		"^": # Jump
			goto_label(text[page].substr(2, len(text[page]) - 2))
		"?": # Conditional jump
			var result := conditional_regex.search(text[page].substr(2, len(text[page]) - 2))
			if Controller.flag(result.get_string(1)) == int(result.get_string(2)):
				goto_label(result.get_string(3))
			else:
				advance_page()
		"$": # Money
			Controller.add_money(int(text[page].substr(2, len(text[page]) - 2)))
			advance_page()
		"*": # Set flag
			var result := flag_regex.search(text[page].substr(2, len(text[page]) - 2))
			Controller.set_flag(result.get_string(1), int(result.get_string(2)))
			advance_page()
		"@": # Set jump point
			event_jump_point = float(text[page].substr(2, len(text[page]) - 2))
			advance_page()
		"]": # Choice
			var stripped_text: String = choice_regex_2.search(text[page]).get_string(1)
			($Text as RichTextLabel).set_bbcode(stripped_text)
			page_length = len(stripped_text)
			
			choice = true
			connect("text_roll_ended", self, "show_choices")


func start_roll():
	page_length = len(text[page])
	insert_bbcode_tags()
	allow_advance = false
	($Text as RichTextLabel).set_bbcode(text[page])
	$TimerRollText.start()
	buffer = true
	$TimerBuffer.start()


func end():
	if reset_state:
		Player.set_state(Player.PlayerState.Move)
	ended = true
	emit_signal("dialogue_ended_jump", event_jump_point)
	emit_signal("dialogue_ended")
	queue_free()

# =====================================================================

func _on_TimerRollText_timeout():
	disp += 1
	if disp < page_length and disp % 3 <= 1:
		Controller.play_sound_oneshot(sound_type, rand_range(0.9, 1.1), -10)
	if disp >= page_length:
		roll = false
		$TimerRollText.stop()
		allow_advance = true
		emit_signal("text_roll_ended")


func _on_TimerBuffer_timeout():
	buffer = false
