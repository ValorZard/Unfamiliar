extends AnimatedSprite

class_name DiscourseCharacter

func _ready():
	$AnimationPlayer.seek(rand_range(0, 2.5))

# =====================================================================

func set_spriteframes(sprframes: SpriteFrames):
	set_sprite_frames(sprframes)
	

func set_sprite(spr: String):
	play(spr)
