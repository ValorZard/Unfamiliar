extends Sprite

var ClockSprites: Dictionary = {
	Controller.GameTime.Six45: "res://Sprites/Props/Interiors/IN_Clock_645.png",
	Controller.GameTime.Seven: "res://Sprites/Props/Interiors/IN_Clock_7.png",
	Controller.GameTime.Seven15: "res://Sprites/Props/Interiors/IN_Clock_715.png",
	Controller.GameTime.Seven30: "res://Sprites/Props/Interiors/IN_Clock_730.png",
	Controller.GameTime.Seven45: "res://Sprites/Props/Interiors/IN_Clock_745.png",
	Controller.GameTime.Eight: "res://Sprites/Props/Interiors/IN_Clock_8.png",
	Controller.GameTime.Three: "res://Sprites/Props/Interiors/IN_Clock_3.png",
	Controller.GameTime.Five: "res://Sprites/Props/Interiors/IN_Clock_5.png"
}

func _ready():
	set_texture(load(ClockSprites[Controller.get_game_time()]))
