extends Polygon2D

class_name ButtonUF

signal hover_start
signal hover_end
signal clicked

const ColorsBlack := PoolColorArray([Color("#0c1323"), Color("#0c1323"), Color("#0c1323"), Color("#0c1323")])
const ColorsWhite := PoolColorArray([Color("#2b4580"), Color("#2b4580"), Color("#2b4580"), Color("#2b4580")])
const ColorsSelect := PoolColorArray([Color("#4776e1"), Color("#4776e1"), Color("#4776e1"), Color("#4776e1")])
const ColorsTransparent := PoolColorArray([Color(0, 0, 0, 0), Color(0, 0, 0, 0), Color(0, 0, 0, 0), Color(0, 0, 0, 0)])
const OutlineWidth: float = 1.5
const Variance: int = 5
const MoveLeniency = 30

const SoundHover := preload("res://Audio/Hover_new.ogg")
const SoundClick := preload("res://Audio/Click.ogg")

var index: int
var target_line: int = -1

var initial_position: Vector2
var pos_start: Vector2
var poly := PoolVector2Array()
var poly_initial := PoolVector2Array()
var active := false
var hover := false
var click := false
var animate := false
var destroy_after_disappear := false

var controller = null

var text_controller = null

onready var label := $Label as Label
onready var spr := $Sprite as Sprite
onready var anim_player := $AnimationPlayer as AnimationPlayer
onready var anim_player_hover := $AnimationPlayerHover as AnimationPlayer

export(String) var button_text
export(Texture) var button_image = null

# warning-ignore:unused_class_variable
export(float) var hover_offset = 0
# warning-ignore:unused_class_variable
export(float) var hover_alpha = 0

export(float) var idle_x = 0
export(float) var idle_y = 0

export(bool) var decisive_click = false

export(bool) var choice_button = true
export(bool) var idle_animation = true
#export(NodePath) var manager = null

# =====================================================================

func _ready():
	#if manager != null:
	#	get_node(manager).add_button(self)
	
	label.set_text(button_text)
	label.show()
	if button_image != null:
		spr.set_texture(button_image)

	for point in polygon:
		var xx = rand_range(-Variance, Variance) if choice_button else 0.0
		var yy = rand_range(-Variance, Variance) if choice_button else 0.0
		var add := Vector2(xx - 55, yy - 15)
		poly.push_back(point + add)
	polygon = poly
	poly_initial = poly
	vertex_colors = ColorsTransparent
	
	initial_position = get_position()
	set_scale(Vector2.ZERO)
	
	if randf() > 0.5:
		$AnimationPlayerIdle.play_backwards("Idle")
		
	$AnimationPlayerIdle.seek(rand_range(0, 2))
	
	if not idle_animation:
		$AnimationPlayerIdle.stop()
	
	
func _process(delta):
	if animate:
		set_position((get_position() if not active and not click else pos_start) + Vector2(idle_x, idle_y))
	else:
		set_position((get_position() if not active and not click else pos_start))
	
#	if Input.is_action_just_pressed("sys_select") and active and hover:
#		if decisive_click:
#			Controller.play_sound_oneshot_from_path("res://Audio/Click 2.ogg", 1.0, 12)
#		else:
#			Controller.play_sound_oneshot(SoundClick, rand_range(0.95, 1.05), 12)
#
#		if choice_button:
#			controller.click_choice(index)
#			text_controller.fade_screen(false)
#
#		click = true
#		emit_signal("clicked")
	
	update()


func _draw():
	draw_polygon(PoolVector2Array([poly[0] + Vector2(-OutlineWidth, OutlineWidth) + Vector2(-hover_offset, hover_offset), poly[1] + Vector2(OutlineWidth, OutlineWidth) + Vector2(hover_offset, hover_offset), poly[2] + Vector2(OutlineWidth, -OutlineWidth) + Vector2(hover_offset, -hover_offset), poly[3] + Vector2(-OutlineWidth, -OutlineWidth) + Vector2(-hover_offset, -hover_offset)]), PoolColorArray([Color(0.17, 0.27, 0.5, hover_alpha), Color(0.17, 0.27, 0.5, hover_alpha), Color(0.17, 0.27, 0.5, hover_alpha), Color(0.17, 0.27, 0.5, hover_alpha)]))
	draw_polygon(PoolVector2Array([poly[0] + Vector2(-OutlineWidth, OutlineWidth), poly[1] + Vector2(OutlineWidth, OutlineWidth), poly[2] + Vector2(OutlineWidth, -OutlineWidth), poly[3] + Vector2(-OutlineWidth, -OutlineWidth)]), ColorsSelect if hover else ColorsWhite)
	draw_polygon(poly, ColorsBlack)
	

# =====================================================================

func appear():
	animate = true
	setup_animation(initial_position)


func set_text_controller(value):
	self.text_controller = value


func set_controller(controller):
	self.controller = controller


func setup_animation(end_pos: Vector2):
	var player := $AnimationPlayer as AnimationPlayer
	pos_start = end_pos
	
	player.get_animation("Appear").track_insert_key(1, 0, Vector2(160, 90), 0.52)
	player.get_animation("Appear").track_insert_key(1, 1, end_pos)
	player.get_animation("Disappear").track_insert_key(1, 0, end_pos, 1.52)
	player.get_animation("Disappear").track_insert_key(1, 1, Vector2(160, 90))
	player.add_animation("Appear2", player.get_animation("Appear").duplicate())
	player.add_animation("Disappear2", player.get_animation("Disappear").duplicate())
	player.add_animation("Select2", player.get_animation("Select").duplicate())
	
	player.rename_animation("Appear", "__temp")
	player.rename_animation("Appear2", "Appear")
	player.remove_animation("__temp")
	
	player.rename_animation("Select", "__temp2")
	player.rename_animation("Select2", "Select")
	player.remove_animation("__temp2")
	
	player.rename_animation("Disappear", "__temp3")
	player.rename_animation("Disappear2", "Disappear")
	player.remove_animation("__temp3")
	
	player.play("Appear")
	
func anim_selected(destroy: bool = true):
	$Button.set_disabled(true)
	active = false
	destroy_after_disappear = destroy
	anim_player.play("Select")
	

func anim_not_selected(destroy: bool = true):
	$Button.set_disabled(true)
	active = false
	destroy_after_disappear = destroy
	anim_player.play("Disappear")
	
	
func get_index() -> int:
	return index
	

func set_index(value: int):
	index = value
	
	
func set_hover(value: bool):
	hover = value
	
	
func set_clicked(value: bool):
	click = value
	

func set_button_text(text: String):
	label.set_text(text)
	

func get_target_line() -> int:
	return target_line
	
	
func set_target_line(target: int):
	target_line = target	
	
# =====================================================================

func _on_AnimationPlayer_animation_finished(anim_name: String):
	if anim_name == "Appear":
		active = true
		$Button.set_disabled(false)
	
	if (anim_name == "Select" or anim_name == "Disappear") and destroy_after_disappear:
		queue_free()


func _button_get_focus():
	if active and not $Button.has_focus():
		$Button.grab_focus()
		Controller.play_sound_oneshot(SoundHover, rand_range(0.95, 1.05))
		if not anim_player_hover.is_playing():
			anim_player_hover.play("Hover")
			anim_player_hover.seek(0)
			
		hover = true
		#emit_signal("hover_start")


func _button_lose_focus():
	$Button.release_focus()
	if active:
		hover = false
		#emit_signal("hover_end")


func _on_Button_pressed() -> void:
	#$Button.set_disabled(true)
	if decisive_click:
		Controller.play_sound_oneshot_from_path("res://Audio/Click 2.ogg", 1.0, 12)
	else:
		Controller.play_sound_oneshot(SoundClick, rand_range(0.95, 1.05), 12)

	if choice_button:
		controller.click_choice(index)
		text_controller.fade_screen(false)

	click = true
	emit_signal("clicked")
