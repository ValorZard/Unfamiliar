extends Polygon2D

const ColorsBlack := PoolColorArray([Color("#0c1323"), Color("#0c1323"), Color("#0c1323"), Color("#0c1323")])
const ColorsWhite := PoolColorArray([Color("#2b4580"), Color("#2b4580"), Color("#2b4580"), Color("#2b4580")])
const ColorsTransparent := PoolColorArray([Color(0, 0, 0, 0), Color(0, 0, 0, 0), Color(0, 0, 0, 0), Color(0, 0, 0, 0)])
const OutlineWidth: float = 1.5
const Variance: int = 5
const MoveLeniency = 30

var target_line_start: int = -1
var target_line_end: int = -1

var pos_start: Vector2
var poly := PoolVector2Array()
var poly_initial := PoolVector2Array()
var active := false
var hover := false

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
	set_position((get_position() if not active else pos_start) + Vector2(idle_x, idle_y))
	update()


func _draw():
	draw_polygon(PoolVector2Array([poly[0] + Vector2(-OutlineWidth, OutlineWidth) + Vector2(-hover_offset, hover_offset), poly[1] + Vector2(OutlineWidth, OutlineWidth) + Vector2(hover_offset, hover_offset), poly[2] + Vector2(OutlineWidth, -OutlineWidth) + Vector2(hover_offset, -hover_offset), poly[3] + Vector2(-OutlineWidth, -OutlineWidth) + Vector2(-hover_offset, -hover_offset)]), PoolColorArray([Color(0.17, 0.27, 0.5, hover_alpha), Color(0.17, 0.27, 0.5, hover_alpha), Color(0.17, 0.27, 0.5, hover_alpha), Color(0.17, 0.27, 0.5, hover_alpha)]))
	draw_polygon(PoolVector2Array([poly[0] + Vector2(-OutlineWidth, OutlineWidth), poly[1] + Vector2(OutlineWidth, OutlineWidth), poly[2] + Vector2(OutlineWidth, -OutlineWidth), poly[3] + Vector2(-OutlineWidth, -OutlineWidth)]), ColorsWhite)
	draw_polygon(poly, ColorsBlack)
	

# =====================================================================

func setup_animation(end_pos: Vector2):
	pos_start = end_pos
	$AnimationPlayer.get_animation("Appear").track_insert_key(1, 0, Vector2(160, 90), 0.52)
	$AnimationPlayer.get_animation("Appear").track_insert_key(1, 1, end_pos)
	$AnimationPlayer.add_animation("Appear2", $AnimationPlayer.get_animation("Appear").duplicate())
	$AnimationPlayer.play("Appear2")
	

func set_button_text(text: String):
	$Label.set_text(text)
	
	
func set_target_lines(start: int, end: int):
	target_line_start = start
	target_line_end = end
	
# =====================================================================

func _on_AnimationPlayer_animation_finished(anim_name: String):
	if anim_name == "Appear2":
		active = true


func _on_AreaHover_mouse_entered():
	if active:
		$AnimationPlayerHover.play("Hover")
		hover = true


func _on_AreaHover_mouse_exited():
	hover = false
