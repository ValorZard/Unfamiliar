extends AnimatedSprite

class_name DiscourseCharacter

func _ready():
	pass

# =====================================================================

func set_spriteframes(sprframes: SpriteFrames):
	set_sprite_frames(sprframes)
	

func set_sprite(spr: String):
	play(spr)
