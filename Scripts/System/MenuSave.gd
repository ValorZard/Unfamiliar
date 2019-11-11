extends Node2D

signal menu_closed

var active := false
var load_mode := false

onready var anim_player := $AnimationPlayer as AnimationPlayer

onready var button1 = $CanvasLayer/Button1 as ButtonUF
onready var button2 = $CanvasLayer/Button2 as ButtonUF
onready var button3 = $CanvasLayer/Button3 as ButtonUF
onready var button4 = $CanvasLayer/Button4 as ButtonUF

onready var buttons: Array = [button1, button2, button3, button4]

# =====================================================================

func _ready():
	_load_save_info()

# =====================================================================

func start(use_background: bool):
	if not use_background:
		$CanvasLayer/ColorRect.hide()
	
	$AnimationPlayer.play("Appear")
	

func set_load_mode(value: bool):
	load_mode = value

# =====================================================================

func _get_info_str(day: int, month: int, year: int, money: int, hour: int, minute: int, playtime: float) -> String:
	return str(day) + " " + Controller.get_month_str(int(month)) + ", " + str(year) + " " \
				+ "                $" + str(money) + "\n" + str(hour) + ":" + str(minute).pad_zeros(2) + \
				"                " + Controller.get_playtime_str(playtime)

func _load_save_info():
	for slot in range(4):
		var f := File.new()
		var fname := "user://data_s" + str(slot + 1) + ".uf"
		if f.file_exists(fname):
			f.open(fname, File.READ)
	
			var slot_datetime = parse_json(f.get_line())
			var slot_playtime := float(f.get_line())
			
			# Skip unnecessary lines
			# warning-ignore:unused_variable
			var buffer: String
			# warning-ignore:unused_variable
			for i in range(4):
				buffer = f.get_line()

			var slot_money := int(f.get_line())
			
			if f.is_open():
				f.close()
			
			var info_str := _get_info_str(slot_datetime.day, slot_datetime.month, slot_datetime.year, slot_money, slot_datetime.hour, slot_datetime.minute, slot_playtime)
				
			(buttons[slot] as ButtonUF).set_button_text(info_str)
		else:
			(buttons[slot] as ButtonUF).set_button_text("EMPTY")
			
			
func _click_slot(slot: int):
	if not load_mode: # Save game
		var dt := OS.get_datetime()
		Controller.save_game(slot, dt)
		(buttons[slot] as ButtonUF).set_button_text(_get_info_str(dt.day, dt.month, dt.year, Controller.get_money(), dt.hour, dt.minute, Controller.get_playtime()))
		yield(get_tree().create_timer(2.5), "timeout")
		anim_player.play("Disappear")
	else: # Load game
		pass
		
# =====================================================================

func _on_Button1_clicked():
	button1.anim_selected()
	button2.anim_not_selected()
	button3.anim_not_selected()
	button4.anim_not_selected()
	_click_slot(0)


func _on_Button2_clicked():
	button1.anim_not_selected()
	button2.anim_selected()
	button3.anim_not_selected()
	button4.anim_not_selected()
	_click_slot(1)


func _on_Button3_clicked():
	button1.anim_not_selected()
	button2.anim_not_selected()
	button3.anim_selected()
	button4.anim_not_selected()
	_click_slot(2)


func _on_Button4_clicked():
	button1.anim_not_selected()
	button2.anim_not_selected()
	button3.anim_not_selected()
	button4.anim_selected()
	_click_slot(3)


func _on_AnimationPlayer_animation_finished(anim_name: String):
	if anim_name == "Appear":
		active = true
	elif anim_name == "Disappear":
		emit_signal("menu_closed")
		queue_free()
