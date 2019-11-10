extends Node2D

var playtimes: PoolRealArray = []
var moneys: PoolIntArray = []

func _ready():
	pass


func load_save_info():
	for slot in range(4):
		var f := File.new()
		var fname := "user://data_s" + str(slot + 1) + ".uf"
		if f.file_exists(fname):
			f.open(fname, File.READ)
	
			var slot_playtime = float(f.get_line())
			
			var buffer: String
			for i in range(4):
				buffer = f.get_line()
			#scn = f.get_line()
			#pos.x = float(f.get_line())
			#pos.y = float(f.get_line())
			#dir = int(f.get_line())
			var slot_money = int(f.get_line())
			#flags = parse_json(f.get_line())
			
			if f.is_open():
				f.close()