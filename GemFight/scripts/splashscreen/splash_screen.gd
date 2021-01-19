extends Node
onready var progress_tick = 0.0
var isLoadingShow = false
var processingTime = 0.001#0.05

var FileSaver = preload("res://global/save_data.gd").new()

func _ready():
	isLoadingShow = true
	loadLocalData()
	
func _process(delta):
	progress_tick += delta
	if isLoadingShow && progress_tick > processingTime:
		progress_tick -= processingTime
		#$LodingControl/VBoxContainer/LoadingProgress.value += 1
		$LodingControl/TextureRect/ProgressBar2.value += 1
		if $LodingControl/TextureRect/ProgressBar2.value == 100:
			#if $LodingControl/VBoxContainer/LoadingProgress.value == 100:
			isLoadingShow = false
			$LodingControl/VBoxContainer.hide()
			gotoNextSceen()

func loadLocalData():
	FileSaver.load_data()
	if GLOBAL.userData != null:
		if GLOBAL.userData.has("mute"):
			if GLOBAL.userData["mute"] == "1":
				AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"),1)
			else:
				AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"),0)
			
func gotoNextSceen():
#	var dd = get_tree().change_scene("res://scenes/Test.tscn")
#	return
	if GLOBAL.userData != null && GLOBAL.userData.has("name"):
		var dd = get_tree().change_scene("res://scenes/MainMenu/LevelMockup.tscn")
	else:
		var dd = get_tree().change_scene("res://scenes/Login/UserLogin.tscn")
		
#	var t = Timer.new()
#	t.set_wait_time(1.0)
#	t.set_one_shot(true)
#	self.add_child(t)
#	t.start()
#	yield(t, "timeout")
##	t.queue_free()
#
#	FileSaver.load_data()
#	if GLOBAL.userData != null:
#		if GLOBAL.userData.has("mute"):
#			if GLOBAL.userData["mute"] == "1":
#				AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"),1)
#			else:
#				AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"),0)
#		if GLOBAL.userData.has("name"):
#			var dd = get_tree().change_scene("res://scenes/MainMenu/LevelMockup.tscn")
#			return
#			pass
#	else:
#		pass
#	var dd = get_tree().change_scene("res://scenes/Login/UserLogin.tscn")
#	pass


#	var dd = get_tree().change_scene("res://scenes/MainMenu/LevelMockup.tscn")

