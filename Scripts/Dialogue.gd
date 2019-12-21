extends Node2D

export(AudioStream) var sound_type

class_name Dialogue

signal dialogue_ended

const Interval := 0.02
const name_regex_pat := "^(.+:).+$"
const name_bbcode_start := "[color=#7ca3ff]"
const name_bbcode_end := "[/color]"

var text: PoolStringArray = []
var page: int = 0
var page_length: int = 0
var disp: int = 0
var roll := false

var text_size: int = 8

var allow_advance := false
var buffer := false

var reset_state := true

var name_regex := RegEx.new()

onready var label := $Text as RichTextLabel

# =====================================================================

func _process(delta):
	label.set_visible_characters(disp)
	
	if Input.is_action_just_pressed("sys_action") and not buffer:
		if allow_advance:
			if page < len(text) - 1:
				disp = 0
				label.set_visible_characters(disp)
				page += 1
				page_length = len(text[page])
				insert_bbcode_tags()
				allow_advance = false
				label.set_bbcode(text[page])
				$TimerRollText.start()
				buffer = true
				$TimerBuffer.start()
			else:
				if reset_state:
					Player.set_state(Player.PlayerState.Move)
				emit_signal("dialogue_ended")
				queue_free()
		else:
			disp = len(text[page])
			buffer = true
			$TimerBuffer.start()

# =====================================================================

func set_text_size(value: int):
	text_size = value
	
	
func set_alt_box_texture():
	$Box.hide()
	$Box2.show()
	

func start(file: String, set: int, reset_state_: bool):
	name_regex.compile(name_regex_pat)
	Player.set_state(Player.PlayerState.NoInput)
	reset_state = reset_state_
	Player.stop_moving()
	load_text_from_file(file, set)
	page_length = len(text[page])
	insert_bbcode_tags()
	($Text as RichTextLabel).set_bbcode(text[page])
	get_node("Text").get("custom_fonts/normal_font").set_size(text_size)
	$TimerRollText.start()
	
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
		if len(line) > 0 and int(line) == set:
			read = true
	if f.is_open():
		f.close()
		
		
func insert_bbcode_tags():
	var mat := name_regex.search(text[page])
	if mat != null:
		if text[page][0] != "#":
			text[page] = text[page].insert(mat.get_end(1), name_bbcode_end)
			text[page] = text[page].insert(mat.get_start(1), name_bbcode_start)
		else:
			text[page] = text[page].replace("#", "")

# =====================================================================

func _on_TimerRollText_timeout():
	disp += 1
	if disp < page_length and disp % 3 <= 1:
		Controller.play_sound_oneshot(sound_type, rand_range(0.9, 1.1), -10)
	if disp >= page_length:
		roll = false
		$TimerRollText.stop()
		allow_advance = true


func _on_TimerBuffer_timeout():
	buffer = false
