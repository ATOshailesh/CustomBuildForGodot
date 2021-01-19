extends Control


var OpenLink
var FileSaver = preload("res://global/save_data.gd").new()

func _ready():
	if Engine.has_singleton("LinkOpen"):
		OpenLink = Engine.get_singleton("LinkOpen")
	
	if GLOBAL.userData.has("mute"):
		if GLOBAL.userData["mute"] == "0":
			$popup/sound/icon.texture = preload("res://art/settings/ON.png")
		else:
			$popup/sound/icon.texture = preload("res://art/settings/OFF.png")
			
#func _notification(what):
#	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
#		print("call back")

func _on_Button_pressed():
	get_parent().resetUserData()
	var dd = get_tree().change_scene("res://scenes/Login/UserLogin.tscn")
	#_on_close_pressed()
	
func _on_close_pressed():
	queue_free()

func _on_close_button_down():
	$popup/close.modulate = Color("dbdc64")

func _on_close_button_up():
	$popup/close.modulate = Color("ffffff")


func _on_btnSound_pressed():
	if $popup/sound/icon.texture == preload("res://art/settings/OFF.png"):
		$popup/sound/icon.texture = preload("res://art/settings/ON.png")
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"),0)
		print("ON SOUND")
		GLOBAL.userData["mute"] = "0"
	else:
		$popup/sound/icon.texture = preload("res://art/settings/OFF.png")
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"),1)
		GLOBAL.userData["mute"] = "1"
		print("OFF SOUND")
	FileSaver._user_data = GLOBAL.userData
	FileSaver.save_data()

func _on_playerinfo_pressed():
	#var PlayerInfo = preload("res://scenes/PlayerSelection/Test_Srolling.tscn").instance()
	var PlayerInfo = preload("res://scenes/Settings/PlayerInfo.tscn").instance()
	add_child(PlayerInfo)
	pass # Replace with function body.


func _on_contactus_pressed():
	if OpenLink != null:
		OpenLink.openLink("https://www.google.com/")
	else:
		OS.shell_open("https://www.google.com/")
	pass # Replace with function body.


func _on_review_pressed():
	if OS.get_name() == "iOS":
		#ar app_id = "585270521"
		#OS.shell_open("https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id="+app_id+"&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8")
		if OpenLink != null:
			OpenLink.rateUs()
	else:
		OS.shell_open("https://play.google.com/store")
