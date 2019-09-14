extends Node2D

const XLower = 55
const XUpper = 285
const YLower = 15
const YUpper = 140

const line_regex_p := "^(\\S+)\\s+(.+)$"
const buttons_regex_p := "^\\s*([^\\r\\n\\t\\f\\v]+)\\s\\(([\\d-]+),\\s*([\\d-]+)\\)\\s*\\[(\\d+),\\s*(\\d+)\\]\\s*$"

var line_regex := RegEx.new()
var buttons_regex := RegEx.new()

var co_target: Node = null
var co_signal: String = ""

const ChoiceButton := preload("res://Instances/ChoiceButton.tscn")

var script_list := []

func _ready():
	randomize()
	
	line_regex.compile(line_regex_p)
	buttons_regex.compile(buttons_regex_p)
	
	yield(get_tree().create_timer(0.5), "timeout")
	load_file("res://Discourses/Test.txt")
	
	for i in script_list:
		parse_discourse_command(i)
		yield(co_target, co_signal)
	
	
func _process(delta):
	pass
	#if Input.is_action_just_pressed("ui_accept"):
	#	TextDisplay.display_text("THIS IS A TEST of how long we can make#this gosh darned text before it#starts to wrap automatically like magic")

# =====================================================================

func create_button(text: String, pos: Vector2, start_line: int, end_line: int):
	var but := ChoiceButton.instance()
	but.set_target_lines(start_line, end_line)
	but.set_position(Vector2(160, 90))
	but.set_button_text(text)
	but.setup_animation(pos)
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
			var buttons: PoolStringArray = text.split("|")
			TextDisplay.fade_screen(true)
			for but in buttons:
				create_button(buttons_regex.search(but).get_string(1), Vector2(160 + int(buttons_regex.search(but).get_string(2)), 90 + int(buttons_regex.search(but).get_string(3))), int(buttons_regex.search(but).get_string(4)), int(buttons_regex.search(but).get_string(5)))
