extends Node2D

class_name Flashback

signal flashback_finished

var regex_pattern := "^(\\w+)\\s+(\\d)\\s+([0-9\\.]+)\\s+(.+)$"
var regex := RegEx.new()

var fb_file: String
var fb_text: PoolStringArray = []
var fb_names: PoolStringArray = []
var fb_bools: PoolIntArray = []
var fb_waits: PoolRealArray = []

var end_anim := true

#var animation_player: AnimationPlayer = null

onready var text_controller := $CanvasLayer/TextDisplay

func _ready():
	regex.compile(regex_pattern)
	
	
func start(transition: bool = true, anim_player: AnimationPlayer = null):
	#animation_player = anim_player
	#anim_player.stop(false)
	if transition:
		$CanvasLayer/ColorRect.get_material().set_shader_param("cutoff", 1)
		$CanvasLayer/ColorRect.hide()
		$CanvasLayer/ColorRect.set_self_modulate(Color(1, 1, 1, 1))
		$CanvasLayer/AnimationPlayer.play("Anim")
	else:
		$CanvasLayer/Art.hide()
		$CanvasLayer/Vignette.hide()
		$CanvasLayer/ColorRect.hide()
		end_anim = false
		show_flashback_text()
		
	
func end():
	emit_signal("flashback_finished")
	queue_free()
	
	
func set_fb_file(file: String):
	fb_file = file
	
	
func set_art(art: Texture):
	if art != null:
		$CanvasLayer/Art.set_texture(art)


func _load_file(path: String):
	var file := File.new()
	file.open(path, File.READ)
	while not file.eof_reached():
		var line: String = file.get_line()
		fb_names.push_back(regex.search(line).get_string(1))
		fb_bools.push_back(int(regex.search(line).get_string(2)))
		fb_waits.push_back(float(regex.search(line).get_string(3)))
		fb_text.push_back(regex.search(line).get_string(4))
	if file.is_open():
		file.close()
		

func show_flashback_text():
	_load_file(fb_file)
	for i in range(len(fb_text)):
		_display_text(fb_text[i], fb_names[i], fb_bools[i] == 1)
		yield(text_controller, "text_ended_button")
		
		if fb_waits[i] > 0:
			text_controller.hide_box()
			#animation_player.play()
			yield(Controller.wait(fb_waits[i]), "timeout")
			#animation_player.stop(false)
	
	if end_anim:
		text_controller.hide_box()
		yield(Controller.wait(0.4), "timeout")
		
		$CanvasLayer/ColorRect.get_material().set_shader_param("cutoff", 1)
		$CanvasLayer/ColorRect.hide()
		$CanvasLayer/ColorRect.set_self_modulate(Color(1, 1, 1, 1))
		$CanvasLayer/AnimationPlayer.play("Anim End")
	else:
		end()
	

func _display_text(text: String, name: String, show_name: bool = true):
	#text_controller.set_name_visible(show_name)
	#text_controller.set_name_text(name)
	text_controller.show_box(text_controller.BoxType.Neutral)
	text_controller.display_text(text)
