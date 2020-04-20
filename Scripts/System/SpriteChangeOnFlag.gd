extends Node

export(Texture) var texture: Texture
export(String) var flag: String
export(int, "EQ,NE,LT,GT,LE,GE") var condition: int
export(int) var value: int

func _ready():
	match condition:
		0: # ==
			if Controller.flag(flag) == value:
				(get_parent() as Sprite).set_texture(texture)
		1: # !=
			if Controller.flag(flag) != value:
				(get_parent() as Sprite).set_texture(texture)
		2: # <
			if Controller.flag(flag) < value:
				(get_parent() as Sprite).set_texture(texture)
		3: # >
			if Controller.flag(flag) > value:
				(get_parent() as Sprite).set_texture(texture)
		4: # <=
			if Controller.flag(flag) <= value:
				(get_parent() as Sprite).set_texture(texture)
		5: # >=
			if Controller.flag(flag) >= value:
				(get_parent() as Sprite).set_texture(texture)
