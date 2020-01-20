extends Node2D

signal story_progress_day1_discourses_finished
signal story_progress_2
signal story_progress_3
signal story_progress_4
signal story_progress_5

export(bool) var is_preview := false

func _ready():
	# Story progress
	if Controller.flag("story_day1_discourses_finished") == 1:
		emit_signal("story_progress_day1_discourses_finished")
	
	# Destroy self if preview
	$CanvasLayer/Money.set_text(str(Controller.get_money()))
	if is_preview:
		queue_free()
