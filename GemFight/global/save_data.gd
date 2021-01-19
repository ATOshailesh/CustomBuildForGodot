extends Node

var _path = "user://save_data.dat"

var _user_data = {}

var file = File.new()

func _ready():
	pass # Replace with function body.

func load_data():
	if(not file.file_exists(_path)):
		save_data()
	file.open(_path, File.READ)
	var loaded_data = Dictionary()
	loaded_data = file.get_var()#parse_json(file.get_as_text())
	_parse_loaded_data(loaded_data)
	file.close()


func save_data():
	file.open(_path,File.WRITE)
	#file.store_string(to_json(_user_data))
	file.store_var(_user_data)
	file.close()


func _parse_loaded_data(loaded_data):
	GLOBAL.userData = loaded_data


func clearAllData():
	file.open(_path,File.WRITE)
	file.store_string(to_json({}))
	file.close()
	print("all data cleared")