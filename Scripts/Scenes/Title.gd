extends Node2D

onready var but1 := get_node("Button1")
onready var but2 := get_node("Button2")
onready var but3 := get_node("Button3")

func _ready():
	Controller.draw_overlay(false)
	Player.hide()


func _on_Button1_clicked() -> void:
	but1.anim_selected()
	but2.anim_not_selected()
	but3.anim_not_selected()
	yield(get_tree().create_timer(0.5), "timeout")
	$AnimationPlayerSetup.play("Teardown Start")
	yield($AnimationPlayerSetup, "animation_finished")
	Controller.draw_overlay(true)
	get_tree().change_scene("res://Scenes/Intro/Train1.tscn")


func _on_Button2_clicked() -> void:
	print("BUTTON 2")


func _on_Button3_clicked() -> void:
	but1.anim_not_selected()
	but2.anim_not_selected()
	but3.anim_selected()
	yield(get_tree().create_timer(0.5), "timeout")
	$AnimationPlayerSetup.play("Teardown")
	yield($AnimationPlayerSetup, "animation_finished")
	get_tree().quit()
