extends Node2D

const RhonaSprite := preload("res://Resources/Sprite Frames/SpriteFrames_Rhona.tres")

func demo_discourse():
	Controller.start_discourse("res://Discourses/d_1_rhona.txt", "Rhona", RhonaSprite)
