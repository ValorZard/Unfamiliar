extends Node2D

var shake := false

onready var viewport: Viewport = get_tree().get_root() as Viewport

# =====================================================================

func _process(delta):
	if shake:
		viewport.set_canvas_transform(Transform2D(0, Vector2(rand_range(-2, 2), rand_range(-2, 2))))
	#else:
	#	viewport.set_canvas_transform(Transform2D(0, Vector2.ZERO))

# =====================================================================

func set_shake(value: bool, time: float = 0):
	shake = value
	if time != 0:
		yield(Controller.wait(time), "timeout")
		shake = false
		viewport.set_canvas_transform(Transform2D(0, Vector2.ZERO))
