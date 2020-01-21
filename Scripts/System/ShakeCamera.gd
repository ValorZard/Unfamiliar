extends Camera2D

var shake := false

# =====================================================================

func _process(delta):
	if shake:
		set_offset(Vector2(rand_range(-2, 2), rand_range(-2, 2)))
	else:
		set_offset(Vector2.ZERO)

# =====================================================================

func unset_current(anim: String):
	current = false


func set_shake(value: bool, time: float = 0):
	shake = value
	if time != 0:
		yield(Controller.wait(time), "timeout")
		shake = false
