extends Node2D

class_name TextDisplay

signal text_ended
signal text_ended_button

export(DynamicFont) var font
export(AudioStream) var sound_type

const Interval := 0.02
const XStart := 36#41
const YStart := 136#132
const LineSpacing := 14
const LineEnd := 200
const WordRegexPattern := "\\b\\w*\\b"

var text: String = ""
var text_length: int = 0

var disp: int = -1
var roll := false

var allow_advance := false
var buffer := false
var t: float = 0
var pause := false

var finished := false

var box_visible := true

var word_regex := RegEx.new()

onready var box_left := $BoxLeft as Polygon2D
onready var box_left_stroke := $BoxLeftStroke as Polygon2D
onready var box_right := $BoxRight as Polygon2D
onready var box_right_stroke := $BoxRightStroke as Polygon2D

enum Modifier { Normal, Red, Green, Blue, Yellow, Shake, Wave, Contract }
enum BoxType { Left, Right, Neutral }

# =====================================================================

func _ready():
	word_regex.compile(WordRegexPattern)
	#$Box.hide()
	#$Namebox.hide()
	box_left.hide()
	box_left_stroke.hide()
	box_right.hide()
	box_right_stroke.hide()
	box_visible = false
	
	
func _process(delta):
	t += 60.0 * delta
	
	if Input.is_action_just_pressed("sys_select") and not buffer:
		if allow_advance:
			allow_advance = false
			emit_signal("text_ended_button")
		elif not finished:
			disp = len(text) - 2
			#allow_advance = true
			finished = true
			buffer = true
			$TimerBuffer.start()
	
	update()
	
	
func _draw():
	if disp >= 0:
		var mod: int = Modifier.Normal
		
		var i: int = 0
		var line: int = 0
		var char_spacing: float = 0
		
		while i < disp + 1:
			if i > 0 and text[i] == " " and char_spacing + len(word_regex.search(text, i).get_string(1)) > LineEnd:
				char_spacing = 0
				line += 1
				i += 1
				
			match text[i]:
				"#":
					char_spacing = 0
					line += 1
				"|":
					if not pause:
						pass
				"$":
					match text[i + 1]:
						"0":
							mod = Modifier.Normal
						"r":
							mod = Modifier.Red
						"b":
							mod = Modifier.Blue
						"g":
							mod = Modifier.Green
						"y":
							mod = Modifier.Yellow
						"s":
							mod = Modifier.Shake
						"w":
							mod = Modifier.Wave
						"c":
							mod = Modifier.Contract
						_:
							mod = Modifier.Normal
			
					i += 1
				_:
					if box_visible:
						match mod:
							Modifier.Normal:
								char_spacing += draw_char(font, Vector2(XStart + char_spacing, YStart + (LineSpacing * line)), text[i], "", Color(1, 1, 1, 1))
							Modifier.Red:
								char_spacing += draw_char(font, Vector2(XStart + char_spacing, YStart + (LineSpacing * line)), text[i], "", Color(1, 0, 0, 1))
							Modifier.Blue:
								char_spacing += draw_char(font, Vector2(XStart + char_spacing, YStart + (LineSpacing * line)), text[i], "", Color(0, 1, 1, 1))
							Modifier.Green:
								char_spacing += draw_char(font, Vector2(XStart + char_spacing, YStart + (LineSpacing * line)), text[i], "", Color(0.5, 1, 0, 1))
							Modifier.Yellow:
								char_spacing += draw_char(font, Vector2(XStart + char_spacing, YStart + (LineSpacing * line)), text[i], "", Color(1, 0.8, 0, 1))
							Modifier.Shake:
								char_spacing += draw_char(font, Vector2(XStart + char_spacing + rand_range(-1, 1), YStart + (LineSpacing * line) + rand_range(-1, 1)), text[i], "", Color(1, 1, 1, 1))
							Modifier.Wave:
								var s: float = 2.0 * t + i * 3.0;
								var shift: float = sin(s * PI * (1.0 / 60.0)) * 3.0
								char_spacing += draw_char(font, Vector2(XStart + char_spacing, YStart + (LineSpacing * line) + shift), text[i], "", Color(1, 1, 1, 1))
							Modifier.Contract:
								var s: float = 2.0 * (t / 2.0) + i * 3.0;
								var shift: float = sin(s * PI * (1.0 / 60.0)) * 3.0
								#var shift: float = s * PI * (1.0 / 60.0) * 6.0
								char_spacing += draw_char(font, Vector2(XStart + char_spacing, YStart + (LineSpacing * line) + shift), text[i], "", Color(1, 0.8, 0, 1))
								#char_spacing += draw_char(font, Vector2(XStart + char_spacing + cos(shift), YStart + (LineSpacing * line) + sin(shift)), text[i], "", Color(1, 0.8, 0, 1))
							_:
								char_spacing += draw_char(font, Vector2(XStart + char_spacing, YStart + (LineSpacing * line)), text[i], "", Color(1, 1, 1, 1))
							
			i += 1
			
# =====================================================================

func show_box(type: int):
	match type:
		BoxType.Left:
			box_left_stroke.show()
			box_left.show()
			box_right_stroke.hide()
			box_right.hide()
		BoxType.Right:
			box_right_stroke.show()
			box_right.show()
			box_left_stroke.hide()
			box_left.hide()
		
	box_visible = true
	

func hide_box():
	box_left_stroke.hide()
	box_left.hide()
	box_right_stroke.hide()
	box_right.hide()
	box_visible = false
	
	
func set_name_visible(visible: bool):
	pass
	
	
func set_name_text(text: String):
	pass
	
	
func set_name_side(right: bool):
	pass
	

func display_text(text: String):
	disp = -1
	finished = false
	self.text = text
	text_length = len(text.replace(" ", ""))
	$TimerRollText.start()
	roll = true
	
	
func set_header_text(text: String):
	$Header/HeaderText.set_text(text)
	
func fade_screen(out: bool):
	$AnimationPlayer.play("Fadeout" if out else "Fadein")
	#$AnimationPlayerHeader.play("Fadein" if out else "Fadeout")

# =====================================================================

func _on_TimerRollText_timeout():
	disp += 1
	#if disp < text_length:
	if disp % 2 == 0:
		Controller.play_sound_oneshot(sound_type, rand_range(0.9, 1.1), -10)
	if disp >= len(text) - 1:
		roll = false
		finished = true
		$TimerRollText.stop()
		emit_signal("text_ended")
		allow_advance = true


func _on_TimerBuffer_timeout():
	buffer = false
