extends Node2D

export(NodePath) var npc_chip: NodePath

var shake := false

onready var viewport: Viewport = get_tree().get_root() as Viewport

# =====================================================================

func _ready():
	if Controller.flag("scn_inn_chip") == 1:
		(get_node(npc_chip) as EventNPC).set_dialogue_set(4)
		return
		
	if Controller.flag("story_day1_discourses_finished") == 1:
		#if Controller.flag("npc_motel_chip") == 0:
		(get_node(npc_chip) as EventNPC).set_dialogue_set(3)
		#else:
			#(get_node(npc_chip) as EventNPC).set_dialogue_set(4)
	

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
