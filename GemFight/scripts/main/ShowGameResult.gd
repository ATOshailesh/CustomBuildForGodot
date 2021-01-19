extends Node2D

onready var winTexture = preload("res://art/extra/gamewin.jpg")
onready var loseTexture = preload("res://art/extra/gameover.jpg")


var isWin
var waitTime = 5
var startTime = 0

func _init():
	self.isWin = GLOBAL.isWin

func _ready():
	self.isWin = GLOBAL.isWin
	GLOBAL.pairManager = null
	NetCmd.player = null
	if isWin:
		$Background.texture = winTexture
		if GLOBAL.winCount != GLOBAL.gameToPlayer:
			$Timer.start()
			$Label.text = "Game Start in " + str(waitTime-startTime)
		else:
			$Label.text = "Try Normal Mode"
			GLOBAL.player1Score = 0
			GLOBAL.winCount = 0
	else:
		if GLOBAL.isNetworked:
			cmdManager.sendYouWin()
			NetCmd.sendYouWin()
		$Background.texture = loseTexture
		$Label.show()
	
	if GLOBAL.isNetworked && not isWin:
		$Timer.start()
	
	pass

func _input(event):
	if event.is_action_pressed("ui_touch") || event is InputEventScreenTouch:
		if not isWin :
			GLOBAL.winCount = 0
			get_tree().change_scene("res://scenes/main/Spoint.tscn")
		else:
			if GLOBAL.winCount == GLOBAL.gameToPlayer:
				get_tree().change_scene("res://scenes/main/Spoint.tscn")


func _on_Timer_timeout():
	if startTime != waitTime :
		startTime += 1
		$Timer.start()
	else:
		GLOBAL.isFromGame = true
		get_tree().change_scene("res://scenes/TwoPlayer/TwoPlayerMobile.tscn")
	$Label.text = "Game Start in " + str(waitTime-startTime)
	
	pass # replace with function body
