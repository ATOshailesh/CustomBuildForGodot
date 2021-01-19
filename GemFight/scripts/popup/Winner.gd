extends Control

signal GoToHome
signal Replay

# Called when the node enters the scene tree for the first time.
func _ready():
	GLOBAL.pairManager = null
	NetCmd.player = null
	NetCmd.winnerPopup = self
	$Msg2.hide()
	$Msg3.hide()
	$btnHome2.hide()
	#GLOBAL.admobObj.loadBanner()
	GLOBAL.admobObj._on_BtnInterstitial_pressed()
	
	if GLOBAL.isPlayerWin == true:
		$Message.text = "You Win."
		playClapSound()
		
		if not GLOBAL.isNetworked : 
			if GLOBAL.selected_mode == 0:
				if GLOBAL.P1_Win_Count != GLOBAL.EASY_GAME:
					print("Go For Selection")
					$btnReplay.icon = preload("res://art/MainMenu/Next.png")
				else:
					print("End Game For Next Level")
					$Msg2.text = "Try Normal Mode"
					$Msg2.show()
					$btnHome2.show()

					hideBothButton()
			elif GLOBAL.selected_mode == 1:
				if GLOBAL.P1_Win_Count != GLOBAL.NORMAL_GAME:
					print("Go For Selection")
					$btnReplay.icon = preload("res://art/MainMenu/Next.png")
				else:
					$Msg2.text = "Try Hard Mode"
					$Msg2.show()
					$btnHome2.show()

					hideBothButton()
			elif GLOBAL.selected_mode == 2:
				if GLOBAL.P1_Win_Count != GLOBAL.HARD_GAME:
					print("Go For Selection")
					if GLOBAL.P1_Win_Round != 2:
						if GLOBAL.P1_lose_Round == 1:
							$btnReplay.icon = preload("res://art/MainMenu/Final_round.png")
						else:	
							$btnReplay.icon = preload("res://art/MainMenu/2nd_round.png")
					else:
						$btnReplay.icon = preload("res://art/MainMenu/Next.png")

				else:
					$btnHome2.show()

					hideBothButton()
	else:
		$Message.text = "You lose."
		if GLOBAL.selected_mode == 2 && not GLOBAL.isNetworked :
			if GLOBAL.P1_lose_Round == 2:
				GLOBAL.P1_Win_Count = 0
				GLOBAL.AI_Play_Index = []
			else:
				if GLOBAL.P1_Win_Round == 1:
					$btnReplay.icon = preload("res://art/MainMenu/Final_round.png")
				else:
					$btnReplay.icon = preload("res://art/MainMenu/2nd_round.png")
		else:
			GLOBAL.P1_Win_Count = 0
			GLOBAL.AI_Play_Index = []
	$BgSound.play()
	
	var t = Timer.new()
	t.set_wait_time(0.5)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	t.connect("timeout",self,"playSound") 
	yield(t, "timeout")


func _on_btnHome_pressed():
	print("Go to Home")
	$ClickSound.play()
	if GLOBAL.isNetworked : 
		NetCmd.send_gotoHome("1")
		NetCmd.winnerPopup = null
	get_tree().change_scene("res://scenes/MainMenu/LevelMockup.tscn")
	emit_signal("GoToHome")
	pass # Replace with function body.


func _on_btnReplay_pressed():
	print("Replay")
	if not GLOBAL.isNetworked : 
		if GLOBAL.selected_mode == 0:
			if GLOBAL.P1_Win_Count != GLOBAL.EASY_GAME:
				print("Go For Selection")
				var playerSelect = preload("res://scenes/PlayerSelection/PlayerSelection.tscn").instance()
				playerSelect.goForAISelection = true
				self.get_parent().add_child(playerSelect)
			else:
				gotoHome()
		elif GLOBAL.selected_mode == 1:
			if GLOBAL.P1_Win_Count != GLOBAL.NORMAL_GAME:
				print("Go For Selection")
				var playerSelect = preload("res://scenes/PlayerSelection/PlayerSelection.tscn").instance()
				playerSelect.goForAISelection = true
				self.get_parent().add_child(playerSelect)
			else:
				gotoHome()
		elif GLOBAL.selected_mode == 2:
			if GLOBAL.P1_Win_Count != GLOBAL.HARD_GAME:
				if GLOBAL.P1_Win_Round != 2 && GLOBAL.P1_lose_Round != 2:
					print("Play second round")
					GLOBAL.pairManager = null
					get_tree().change_scene("res://scenes/TwoPlayer/Home.tscn")
				else:
					print("Go For Selection")
					GLOBAL.P1_Win_Round = 0
					GLOBAL.P1_lose_Round = 0
					var playerSelect = preload("res://scenes/PlayerSelection/PlayerSelection.tscn").instance()
					playerSelect.goForAISelection = true
					self.get_parent().add_child(playerSelect)
			else:
				gotoHome()
	else:
		NetCmd.send_gotoHome("0")
		get_tree().change_scene("res://scenes/TwoPlayer/Home.tscn")
		emit_signal("Replay")
	$ClickSound.play()
	pass # Replace with function body.

func replayMessage(isReplay):
	if isReplay:
		$Msg3.text = "Your opponet is ready for Replay."
	else:
		$Msg3.text = "Connection with opponent lost."
		$btnReplay.disabled = true
	$Msg3.show()
		
func gotoHome():
	print("End Game For Next Level") 
	GLOBAL.P1_Win_Round = 0
	GLOBAL.P1_lose_Round = 0
	GLOBAL.P1_Win_Count = 0
	GLOBAL.AI_Play_Index = []
	get_tree().change_scene("res://scenes/TwoPlayer/Home.tscn")
	
func playSound():
	if GLOBAL.isPlayerWin:
		$LoseSound.stream = preload("res://art/sounds/YouwinSound.wav")
	else:
		$LoseSound.stream = preload("res://art/sounds/YouLoseSound.wav")
	$LoseSound.play()

func playClapSound():
	var audioPlayer = AudioStreamPlayer.new()
	audioPlayer.stream = load("res://art/sounds/clap.wav")
	audioPlayer.set_bus("BackGround")
	print(audioPlayer.get_bus())
	add_child(audioPlayer)
	audioPlayer.play()

func hideBothButton():
	$btnHome.hide()
	$btnReplay.hide()

#func _on_interstitial_loaded():
#	print("Interstitial loaded")
#	if isShowAd:
#		admob._on_BtnInterstitial_pressed()
#		isShowAd = false