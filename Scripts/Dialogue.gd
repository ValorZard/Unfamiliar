extends Node2D

class_name Dialogue

signal dialogue_ended

const Interval := 0.02

var text: PoolStringArray = []
var page: int = 0
var disp: int = 0
var roll := false

var allow_advance := false
var buffer := false

onready var label: Label = $Text

# =====================================================================

func _process(delta):
	label.set_text(text[page])
	label.set_visible_characters(disp)
	
	if Input.is_action_just_pressed("sys_select") and not buffer:
		if allow_advance:
			if page < len(text) - 1:
				disp = 0
				page += 1
				allow_advance = false
				$TimerRollText.start()
				buffer = true
				$TimerBuffer.start()
			else:
				Player.set_state(Player.PlayerState.Move)
				emit_signal("dialogue_ended")
				queue_free()
		else:
			disp = len(text[page])
			buffer = true
			$TimerBuffer.start()

# =====================================================================

func start(file: String):
	Player.set_state(Player.PlayerState.NoInput)
	Player.stop_moving()
	load_text_from_file(file)
	$TimerRollText.start()
	
# =====================================================================

func load_text_from_file(file: String):
	var f := File.new()
	f.open(file, File.READ)
	while not f.eof_reached():
		text.push_back(f.get_line())
	if f.is_open():
		f.close()

# =====================================================================

func _on_TimerRollText_timeout():
	disp += 1
	if disp >= len(text[page]):
		roll = false
		$TimerRollText.stop()
		#$TimerSound.stop()
		allow_advance = true


func _on_TimerBuffer_timeout():
	buffer = false
