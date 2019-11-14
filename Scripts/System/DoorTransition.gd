extends Node2D

func destroy(dummy: String):
	queue_free()


func restore_player_movement(dummy: String):
	Player.set_state(Player.PlayerState.Move)
