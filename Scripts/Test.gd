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

var line_regex := RegEx.new()
var buttons_regex := RegEx.new()
var choices_regex = RegEx.new()

var co_target: Node = null
var co_signal: String = ""

const ChoiceButton := preload("res://Instances/ChoiceButton.tscn")

var script_list := []
var buttons_list := []

var list_index: int = 0
var response := false
var response_end: int = -1
var response_end_total: int = -1

func _ready():
	randomize()
	
	line_regex.compile(line_regex_p)
	buttons_regex.compile(buttons_regex_p)
	choices_regex.compile(choices_regex_p)
	
	yield(get_tree().create_timer(0.5), "timeout")
	load_file("res://Discourses/Test.txt")

	list_index = 0
	while list_index < len(script_list):
		parse_discourse_command(script_list[list_index])
		yield(co_target, co_signal)
		
		if response and list_index == response_end:
			list_index = response_end_total
			response = false
		else:
			list_index += 1
	
	
#func _process(delta):
	#pass
	#if Input.is_action_just_pressed("ui_accept"):
	#	TextDisplay.display_text("THIS IS A TEST of how long we can make#this gosh darned text before it#starts to wrap automatically like magic")

# =====================================================================

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

# =====================================================================

func create_button(text: String, pos: Vector2, index: int, start_line: int, end_line: int):
	var but := ChoiceButton.instance()
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
	var text = line_regex.search(command).get_string(2)
	match line_regex.search(command).get_string(1):
		">":
			co_target = TextDisplay
			co_signal = "text_ended_button"
			TextDisplay.display_text(text)
		">>":
			co_target = TextDisplay
			co_signal = "text_ended"
			TextDisplay.set_header_text(text)
			TextDisplay.display_text(text)
		"[":
			co_target = self
			co_signal = "choice_clicked"
			response_end_total = int(choices_regex.search(text).get_string(1)) - 1
			var buttons: PoolStringArray = choices_regex.search(text).get_string(2).split("|")
			TextDisplay.fade_screen(true)
			var i: int = 0
			for but in buttons:
				create_button(buttons_regex.search(but).get_string(1), Vector2(160 + int(buttons_regex.search(but).get_string(2)), 90 + int(buttons_regex.search(but).get_string(3))), i, int(buttons_regex.search(but).get_string(4)), int(buttons_regex.search(but).get_string(5)))
				i += 1
		#_:
		#	co_target = self
		#	co_signal = "ignore_line"
		#	emit_signal("ignore_line")
