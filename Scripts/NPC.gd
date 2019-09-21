extends KinematicBody2D

export(String, FILE, "*.txt") var dialogue_file

var in_range := false

onready var interact: Sprite = $Interact

# =====================================================================

func _ready():
	interact.hide()
	
	
func _process(delta):
	set_z_index(int(get_position().y))
	
	if Input.is_action_just_pressed("sys_select") and in_range and Controller.get_player_state() == Controller.PlayerState.Move:
		interact.hide()
		yield(Controller.dialogue(dialogue_file), "dialogue_ended")
		interact.show()
	
# =====================================================================

func _on_InteractArea_area_entered(area: Area2D):
	if area.is_in_group("PlayerSight"):
		in_range = true
		interact.show()


func _on_InteractArea_area_exited(area: Area2D):
	if area.is_in_group("PlayerSight"):
		in_range = false
		interact.hide()
