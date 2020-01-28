extends Sprite

const ClockSprites: Dictionary = {
	Controller.GameTime.SixThirty: "res://Sprites/Props/Interiors/IN_Clock_630.png",
	Controller.GameTime.SevenThirty: "res://Sprites/Props/Interiors/IN_Clock_7.png",
	Controller.GameTime.Eight: "res://Sprites/Props/Interiors/IN_Clock_8.png",
	Controller.GameTime.Nine: "res://Sprites/Props/Interiors/IN_Clock_9.png",
	Controller.GameTime.Twelve: "res://Sprites/Props/Interiors/IN_Clock_12.png",
	Controller.GameTime.Three: "res://Sprites/Props/Interiors/IN_Clock_3.png",
	Controller.GameTime.Five: "res://Sprites/Props/Interiors/IN_Clock_5.png",
}

func _ready():
	set_texture(load(ClockSprites[Controller.get_game_time()]))
