extends Node

signal scene_loaded(scene, path)

var queue := []

onready var thread := Thread.new()
onready var mutex := Mutex.new()

# =====================================================================

func _exit_tree():
	if thread.is_active():
		thread.wait_to_finish()

# =====================================================================

func queue_scene(path: String):
	mutex.lock()
	if queue.empty():
		if thread.is_active():
			thread.wait_to_finish()
		thread.start(self, "load_scene_from_queue")
	queue.push_back(path)
	mutex.unlock()
		
		
func load_scene_from_queue(userdata):
	while len(queue) != 0:
		mutex.lock()
		var path: String = queue.pop_back()
		mutex.unlock()
		var scn := load(path) as PackedScene
		var inst := scn.instance() as Node2D
		emit_signal("scene_loaded", inst, path)
