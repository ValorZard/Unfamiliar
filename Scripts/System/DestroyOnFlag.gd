extends Node

export(String) var flag: String
export(int, "EQ,NE,LT,GT,LE,GE") var condition: int
export(int) var value: int

func _ready():
	match condition:
		0: # ==
			if Controller.flag(flag) == value:
				get_parent().queue_free()
		1: # !=
			if Controller.flag(flag) != value:
				get_parent().queue_free()
		2: # <
			if Controller.flag(flag) < value:
				get_parent().queue_free()
		3: # >
			if Controller.flag(flag) > value:
				get_parent().queue_free()
		4: # <=
			if Controller.flag(flag) <= value:
				get_parent().queue_free()
		5: # >=
			if Controller.flag(flag) >= value:
				get_parent().queue_free()
