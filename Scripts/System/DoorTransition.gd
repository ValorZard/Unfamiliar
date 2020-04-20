extends Node2D

func destroy(dummy: String):
	queue_free()


func restore_player_movement(dummy: String):
	if not Player.is_in_event():
		Player.set_state(Player.PlayerState.Move)
		Player.set_in_door_transition(false)
