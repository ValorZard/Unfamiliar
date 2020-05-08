extends Polygon2D

class_name ButtonUF

signal hover_start
signal hover_end
signal clicked

const ColorsBlack := PoolColorArray([Color("#0c1323"), Color("#0c1323"), Color("#0c1323"), Color("#0c1323")])
const ColorsShaded := PoolColorArray([Color("#3d5999"), Color("#3d5999"), Color("#3d5999"), Color("#3d5999")])

const ColorsWhite := PoolColorArray([Color("#2b4580"), Color("#2b4580"), Color("#2b4580"), Color("#2b4580")])
const ColorsSelect := PoolColorArray([Color("#4776e1"), Color("#4776e1"), Color("#4776e1"), Color("#4776e1")])
const ColorsTransparent := PoolColorArray([Color(0, 0, 0, 0), Color(0, 0, 0, 0), Color(0, 0, 0, 0), Color(0, 0, 0, 0)])

const OutlineWidth: float = 1.5
const Variance: int = 5
const MoveLeniency = 30

const SoundHover := preload("res://Audio/Hover_new.ogg")
const SoundClick := preload("res://Audio/Click.ogg")
const SoundClickDecisive := preload("res://Audio/Click 2.ogg")

var index: int
var target_line: int = -1

var shaded := false

var initial_position: Vector2
var pos_start: Vector2
var poly := PoolVector2Array()
var poly_initial := PoolVector2Array()
var active := false
var hover := false
var click := false
var animate := false
var destroy_after_disappear := false
var sound := false

var controller = null

var text_controller = null

var end_choice_button := false

onready var label := $Label as Label
onready var spr := $Sprite as Sprite
onready var anim_player := $AnimationPlayer as AnimationPlayer
onready var anim_player_hover := $AnimationPlayerHover as AnimationPlayer
onready var but := $Button as Button

export(String) var button_text
export(Texture) var button_image = null

# warning-ignore:unused_class_variable
export(float) var hover_offset = 0
# warning-ignore:unused_class_variable
export(float) var hover_alpha = 0

export(float) var idle_x = 0
export(float) var idle_y = 0

export(bool) var decisive_click = false

export(bool) var choice_button := true
export(bool) var idle_animation := true
export(bool) var selection_animation := true
export(bool) var fast_fade := false
export(bool) var image_only := false
#export(NodePath) var manager = null

# =====================================================================

func _ready():
	#if manager != null:
	#	get_node(manager).add_button(self)
	
	label.set_text(button_text)
	label.show()
	if button_image != null:
		spr.set_texture(button_image)
		
	#if image_only:
	#	label.hide()
	#	set_self_modulate(Color(1, 1, 1, 0))

	for point in polygon:
		var xx = rand_range(-Variance / 2.0, Variance / 2.0) if end_choice_button else rand_range(-Variance, Variance) if choice_button else 0.0
		var yy = rand_range(-Variance / 2.0, Variance / 2.0) if end_choice_button else rand_range(-Variance, Variance) if choice_button else 0.0
		var add := Vector2(xx - 55, yy - 15)
		poly.push_back(point + add + (Vector2(-26 if point.x > 0 else 26, -4 if point.y > 0 else 4) if end_choice_button else Vector2.ZERO))
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
	
	update()


func _draw():
	var col: Color = Color(0.17, 0.27, 0.5, hover_alpha if not image_only else 0.0)
	draw_polygon(PoolVector2Array([poly[0] + Vector2(-OutlineWidth, OutlineWidth) + Vector2(-hover_offset, hover_offset), poly[1] + Vector2(OutlineWidth, OutlineWidth) + Vector2(hover_offset, hover_offset), poly[2] + Vector2(OutlineWidth, -OutlineWidth) + Vector2(hover_offset, -hover_offset), poly[3] + Vector2(-OutlineWidth, -OutlineWidth) + Vector2(-hover_offset, -hover_offset)]), PoolColorArray([col, col, col, col]))
	draw_polygon(PoolVector2Array([poly[0] + Vector2(-OutlineWidth, OutlineWidth), poly[1] + Vector2(OutlineWidth, OutlineWidth), poly[2] + Vector2(OutlineWidth, -OutlineWidth), poly[3] + Vector2(-OutlineWidth, -OutlineWidth)]), PoolColorArray([Color(1, 1, 1, 0)]) if image_only else (ColorsSelect if hover else ColorsWhite))
	draw_polygon(poly, PoolColorArray([Color(1, 1, 1, 0)]) if image_only else (ColorsShaded if shaded else ColorsBlack))
	
# =====================================================================

func appear(instant: bool = false):
	animate = true
	setup_animation(initial_position, instant)


func set_text_controller(value):
	self.text_controller = value


func set_controller(contr):
	self.controller = contr
	
	
func set_end_choice_button(value: bool):
	end_choice_button = value
	
	
func set_shaded(value: bool):
	shaded = value


func setup_animation(end_pos: Vector2, instant: bool):
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
	if instant:
		player.seek(0.9)
	
	
func anim_selected(destroy: bool = true):
	but.set_disabled(true)
	active = false
	destroy_after_disappear = destroy
	anim_player.play("Select Fast" if fast_fade else "Select")
	

func anim_not_selected(destroy: bool = true):
	but.set_disabled(true)
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
	
	
func get_button_path() -> NodePath:
	return get_node("Button").get_path()
	
	
func set_neighbor_previous(value):
	(get_node("Button") as Button).focus_neighbour_top = value.get_button_path()
	
	
func set_neighbor_next(value):
	(get_node("Button") as Button).focus_neighbour_bottom = value.get_button_path()
	
# =====================================================================

func _on_AnimationPlayer_animation_finished(anim_name: String):
	if anim_name == "Appear":
		active = true
		but.set_disabled(image_only)
	
	if (anim_name == "Select" or anim_name == "Select Fast" or anim_name == "Disappear") and destroy_after_disappear:
		queue_free()


func _button_get_focus():
	if active and not image_only:
		but.grab_focus()
		if sound:
			Controller.play_sound_oneshot(SoundHover, rand_range(0.95, 1.05))
			sound = false
		if not anim_player_hover.is_playing():
			anim_player_hover.play("Hover")
			anim_player_hover.seek(0)
			
		hover = true
		
		
func _button_get_focus_kb():
	sound = true
	_button_get_focus()
	
	
func _button_get_focus_mouse():
	_button_get_focus()


func _button_lose_focus():
	but.release_focus()
	if active:
		hover = false


func _on_Button_pressed() -> void:
	if decisive_click:
		Controller.play_sound_oneshot(SoundClickDecisive, 1.0, 12)
	else:
		Controller.play_sound_oneshot(SoundClick, rand_range(0.95, 1.05), 12)

	if choice_button:
		controller.click_choice(index)
		if end_choice_button:
			text_controller.show_end_text(false)
		else:
			text_controller.fade_screen(false)

	click = selection_animation
	emit_signal("clicked")
