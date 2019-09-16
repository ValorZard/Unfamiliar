extends Node2D

class_name Dialogue

signal text_ended
signal text_ended_button

export(DynamicFont) var font

const Interval := 0.02
const XStart := 41
const YStart := 132
const LineSpacing := 14

var text: String = ""
#var page: int = 0
var disp: int = -1
var roll := false

var allow_advance := false
var buffer := false
var t: float = 0
var pause := false

var box_visible := true

enum Modifier {Normal, Red, Green, Blue, Yellow, Shake, Wave}

# =====================================================================

func _ready():
	$Box.hide()
	$Namebox.hide()
	box_visible = false
	
	
func _process(delta):
	t += 60.0 * delta
	
	if Input.is_action_just_pressed("ui_accept") and allow_advance:
		emit_signal("text_ended_button")
	
	update()
	
	
func _draw():
	if disp >= 0:
		var mod: int = Modifier.Normal
		
		var i: int = 0
		var line: int = 0
		var char_spacing: float = 0
		
		while i < disp + 1:
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
							_:
								char_spacing += draw_char(font, Vector2(XStart + char_spacing, YStart + (LineSpacing * line)), text[i], "", Color(1, 1, 1, 1))
							
			i += 1
			
# =====================================================================

func show_box():
	$Box.show()
	$Namebox.show()
	box_visible = true
	

func hide_box():
	$Box.hide()
	$Namebox.hide()
	box_visible = false
	
	
func set_name_text(text: String):
	$Namebox/NameText.set_text(text)
	$Namebox.margin_right = $Namebox.margin_left + font.get_string_size(text).x + 7
	
	
#func set_name_side(right: bool):
	#if right:
	#	$Namebox/NameText.set_align(Label.ALIGN_RIGHT)
	#	$Namebox/NameText.margin_left = 244
	#else:
	#	$Namebox/NameText.set_align(Label.ALIGN_LEFT)
	#	$Namebox/NameText.margin_left = 4
	

func display_text(text: String):
	disp = -1
	self.text = text
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
	if disp >= len(text) - 1:
		roll = false
		$TimerRollText.stop()
		$TimerSound.stop()
		emit_signal("text_ended")
		allow_advance = true
