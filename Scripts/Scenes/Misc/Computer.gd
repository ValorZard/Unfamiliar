extends Node2D

#var press_key := false

export(Array, AudioStream) var key_sounds
export(AudioStream) var spacebar_sound

func _input(event: InputEvent):
	if event is InputEventKey:
		#if not event.is_pressed():
		#	press_key = false
		
		if event.is_pressed():
			if event.get_scancode() != KEY_SPACE:
				Controller.play_sound_oneshot(key_sounds[int(round(rand_range(0, len(key_sounds) - 1)))], rand_range(0.9, 1.1))
			else:
				Controller.play_sound_oneshot(spacebar_sound, rand_range(0.9, 1.1))
			
			
			if event.get_scancode() == KEY_BACKSPACE:
				$Text.text.erase(0, 2)
				print("TEST")
			else:
				$Text.text += char(event.get_scancode())
			#press_key = true
			
		
