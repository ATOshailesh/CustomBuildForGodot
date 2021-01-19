extends Node2D

var DataManager = preload("res://global/save_data.gd")


var fileData
func _ready():
	#$AudioPlayer.play()
	fileData = DataManager.new()
	add_child(fileData)
	fileData.load_data()
	NetCmd.connect("conntion_done",self,"openMobileScreen")
	if OS.get_name() == "iOS":
		var GMC = preload("res://global/GameCenter.gd")
		GLOBAL.ios_GameCenter = GMC.GameCenterInfo.new()
	pass

func _on_easy_pressed():
	GLOBAL.selected_mode = 0
	#fileData.clearAllData()
	get_tree().change_scene("res://scenes/TwoPlayer/TwoPlayerMobile.tscn")
	pass #replace with function body

func _on_Normal_pressed():
	GLOBAL.selected_mode = 1
	get_tree().change_scene("res://scenes/TwoPlayer/TwoPlayerMobile.tscn")
	#fileData.load_data()
	pass #replace with function body

func _on_Hard_pressed():
	GLOBAL.selected_mode = 2
	get_tree().change_scene("res://scenes/TwoPlayer/TwoPlayerMobile.tscn")
	pass #replace with function body

func _on_2_Player_pressed():
	GLOBAL.selected_mode = 0
	get_tree().change_scene("res://scripts/Network/Lobby.tscn")

func _on_NetPlay_pressed():
	NetCmd.goToConnect()
	pass # Replace with function body.

func openMobileScreen():
	GLOBAL.isNetworked = true
	NetCmd.movedToScene = true
	get_tree().change_scene("res://scenes/TwoPlayer/TwoPlayerMobile.tscn")