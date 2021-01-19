extends Control
#extends "res://Script/LevelMockup.gd"

var colorDefault = Color("ffffff")
var colorPressed = Color("f7ec38")

var Loader = preload("res://scenes/Loader/Loader.tscn").instance()

# Called when the node enters the scene tree for the first time.
func _ready():
	$GameTypePopup.connect("close_popup",self,"_on_btnClose_popup_pressed")
	$GameTypePopup.connect("mode_set",self,"_on_popup_ModeSelected")
	NetCmd.connect("conntion_done",self,"_open_home_screen")  	# loadInitData()
	NetCmd.connect("conntion_error",self,"_conntion_fail")
	
	
func _on_btn1Player_pressed():
	GLOBAL.AI_Play_Index = []
	GLOBAL.isNetworked = false
	NetCmd.movedToScene = false
	$ClickSound.play()
	$GameTypePopup.show()
	GLOBAL.player1Score = 0
	#get_tree().change_scene("res://scenes/PlayerSelection/PlayerSelection.tscn")
	

func _on_btn2Player_pressed():
	$ClickSound.play()
	#showComingsoonPopup()
	
	GLOBAL.AI_Play_Index = []
	GLOBAL.selected_mode = 1
	$ClickSound.play()
	GLOBAL.player1Score = 0
	#NetCmd.goToConnect()

	var playerSelect = preload("res://scenes/PlayerSelection/PlayerSelection.tscn").instance()
	playerSelect.isTwoPlay = true
	self.get_parent().add_child(playerSelect)
	playerSelect.connect("go_connect",self,"_go_to_connect")

func showComingsoonPopup():
#	var comingSoonPopup = preload("res://scenes/popup/MessagePopup.tscn").instance()
#	add_child(comingSoonPopup)
#	comingSoonPopup.show()
	$MessagePopup.show()
	
func _on_popup_ModeSelected():
	$PopupPanel.hide()
	$GameTypePopup.hide()
	GLOBAL.P1_Win_Count = 0
	GLOBAL.P1_Win_Round = 0
	GLOBAL.P1_lose_Round = 0
	var playerSelect = preload("res://scenes/PlayerSelection/PlayerSelection.tscn").instance()
	self.get_parent().add_child(playerSelect)
	#get_tree().change_scene("res://scenes/PlayerSelection/PlayerSelection.tscn")

func _on_btnClose_popup_pressed():
	$PopupPanel.hide()
	$GameTypePopup.hide()
	
func _on_btnQuit_pressed():
	_notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)

func _notification(what):
    if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
        get_tree().quit() # default behavior

func _go_to_connect():
	NetCmd.goToConnect()
	
func _conntion_fail():
	pass
	
func _on_btnSetting_pressed():
	$ClickSound.play()

func _on_btnPlay_pressed():
	print("Play")
	$ClickSound.play()
	get_tree().change_scene("res://scenes/TwoPlayer/Home.tscn")


#func loadInitData():
#	#NetCmd.connect("conntion_done",self,"_open_home_screen")
#	if OS.get_name() == "iOS":
#		var GMC = preload("res://global/GameCenter.gd")
#		GLOBAL.ios_GameCenter = GMC.GameCenterInfo.new()

func _open_home_screen():
	GLOBAL.isNetworked = true
	NetCmd.movedToScene = true
	print("Connection done and Move home screen.")
	get_tree().change_scene("res://scenes/TwoPlayer/Home.tscn")
	


func _on_btn1Player_button_down():
	$btn1Player.modulate = colorPressed
	pass # Replace with function body.
	
func _on_btn1Player_button_up():
	$btn1Player.modulate = colorDefault
	pass # Replace with function body.


func _on_btn2Player_button_down():
	$btn2Player.modulate = colorPressed
	pass # Replace with function body.


func _on_btn2Player_button_up():
	$btn2Player.modulate = colorDefault
	pass # Replace with function body.


func _on_btnSetting_button_down():
	$HBoxContainer/btnSetting.modulate = colorPressed
	pass # Replace with function body.


func _on_btnSetting_button_up():
	$HBoxContainer/btnSetting.modulate = colorDefault
	pass # Replace with function body.


func _on_btnPlay_button_down():
	$HBoxContainer/btnPlay.modulate = colorPressed
	pass # Replace with function body.


func _on_btnPlay_button_up():
	$HBoxContainer/btnPlay.modulate = colorDefault
	pass # Replace with function body.


func _on_btnShare_button_down():
	$HBoxContainer/btnShare.modulate = colorPressed

func _on_btnShare_button_up():
	$HBoxContainer/btnShare.modulate = colorDefault
	

