extends KinematicBody2D

onready var interact: Sprite = $Interact

# =====================================================================

func _ready():
	interact.hide()
	
	
func _process(delta):
	set_z_index(int(get_position().y))
	
# =====================================================================

func _on_InteractArea_area_entered(area: Area2D):
	if area.is_in_group("PlayerSight"):
		interact.show()


func _on_InteractArea_area_exited(area: Area2D):
	if area.is_in_group("PlayerSight"):
		interact.hide()
