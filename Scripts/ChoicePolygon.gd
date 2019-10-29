extends Polygon2D

signal clicked

const ColorsBlack := PoolColorArray([Color("#0c1323"), Color("#0c1323"), Color("#0c1323"), Color("#0c1323")])
const ColorsWhite := PoolColorArray([Color("#2b4580"), Color("#2b4580"), Color("#2b4580"), Color("#2b4580")])
const ColorsTransparent := PoolColorArray([Color(0, 0, 0, 0), Color(0, 0, 0, 0), Color(0, 0, 0, 0), Color(0, 0, 0, 0)])
const OutlineWidth: float = 1.5
const Variance: int = 5
const MoveLeniency = 30

const SoundHover := preload("res://Audio/Hover_new.ogg")
const SoundClick := preload("res://Audio/Click.ogg")

var index: int

var target_line_start: int = -1
var target_line_end: int = -1

var pos_start: Vector2
var poly := PoolVector2Array()
var poly_initial := PoolVector2Array()
var active := false
var hover := false
var click := false

var controller = null

var text_controller = null

export(float) var hover_offset = 0
export(float) var hover_alpha = 0

export(float) var idle_x = 0
export(float) var idle_y = 0

# =====================================================================

func _ready():
	for point in polygon:
		var add := Vector2(rand_range(-Variance, Variance) - 55, rand_range(-Variance, Variance) - 15)
		poly.push_back(point + add)
	polygon = poly
	poly_initial = poly
	vertex_colors = ColorsTransparent
	
	if randf() > 0.5:
		$AnimationPlayerIdle.play_backwards("Idle")
	$AnimationPlayerIdle.seek(rand_range(0, 2))
	
	
func _process(delta):
	set_position((get_position() if not active and not click else pos_start) + Vector2(idle_x, idle_y))
	
	if Input.is_action_just_pressed("sys_select") and active and hover:
		#print("TEST")
		Controller.play_sound_oneshot(SoundClick, rand_range(0.95, 1.05), 12)
		controller.click_choice(index)
		text_controller.fade_screen(false)
		#$AnimationPlayer.play("Disappear2")
		click = true
		emit_signal("clicked")
	
	update()


func _draw():
	draw_polygon(PoolVector2Array([poly[0] + Vector2(-OutlineWidth, OutlineWidth) + Vector2(-hover_offset, hover_offset), poly[1] + Vector2(OutlineWidth, OutlineWidth) + Vector2(hover_offset, hover_offset), poly[2] + Vector2(OutlineWidth, -OutlineWidth) + Vector2(hover_offset, -hover_offset), poly[3] + Vector2(-OutlineWidth, -OutlineWidth) + Vector2(-hover_offset, -hover_offset)]), PoolColorArray([Color(0.17, 0.27, 0.5, hover_alpha), Color(0.17, 0.27, 0.5, hover_alpha), Color(0.17, 0.27, 0.5, hover_alpha), Color(0.17, 0.27, 0.5, hover_alpha)]))
	draw_polygon(PoolVector2Array([poly[0] + Vector2(-OutlineWidth, OutlineWidth), poly[1] + Vector2(OutlineWidth, OutlineWidth), poly[2] + Vector2(OutlineWidth, -OutlineWidth), poly[3] + Vector2(-OutlineWidth, -OutlineWidth)]), ColorsWhite)
	draw_polygon(poly, ColorsBlack)
	
# =====================================================================

func set_text_controller(value):
	self.text_controller = value


func set_controller(controller):
	self.controller = controller


func setup_animation(end_pos: Vector2):
	pos_start = end_pos
	$AnimationPlayer.get_animation("Appear").track_insert_key(1, 0, Vector2(160, 90), 0.52)
	$AnimationPlayer.get_animation("Appear").track_insert_key(1, 1, end_pos)
	$AnimationPlayer.get_animation("Disappear").track_insert_key(1, 0, end_pos, 1.52)
	$AnimationPlayer.get_animation("Disappear").track_insert_key(1, 1, Vector2(160, 90))
	$AnimationPlayer.add_animation("Appear2", $AnimationPlayer.get_animation("Appear").duplicate())
	$AnimationPlayer.add_animation("Disappear2", $AnimationPlayer.get_animation("Disappear").duplicate())
	$AnimationPlayer.add_animation("Select2", $AnimationPlayer.get_animation("Select").duplicate())
	$AnimationPlayer.play("Appear2")
	
	
func anim_selected():
	active = false
	$AnimationPlayer.play("Select2")
	

func anim_not_selected():
	active = false
	$AnimationPlayer.play("Disappear2")
	
	
func get_index() -> int:
	return index
	

func set_index(value: int):
	index = value
	

func set_button_text(text: String):
	$Label.set_text(text)
	
	
func get_target_line_start() -> int:
	return target_line_start
	

func get_target_line_end() -> int:
	return target_line_end
	
	
func set_target_lines(start: int, end: int):
	target_line_start = start
	target_line_end = end
	
# =====================================================================

func _on_AnimationPlayer_animation_finished(anim_name: String):
	if anim_name == "Appear2":
		active = true
	
	if anim_name == "Select2" or anim_name == "Disappear2":
		queue_free()


func _on_AreaHover_mouse_entered():
	if active:
		Controller.play_sound_oneshot(SoundHover, rand_range(0.95, 1.05))
		$AnimationPlayerHover.play("Hover")
		$AnimationPlayerHover.seek(0)
		hover = true


func _on_AreaHover_mouse_exited():
	hover = false
