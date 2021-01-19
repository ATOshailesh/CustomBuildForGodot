extends Node

onready var Player1Grid = $Grid1/Player1Grid
onready var Player2Grid = $Grid2/Player2Grid

var character_p1 
var character_p2 

var p1_selectIndex
var p2_selectIndex

var objePattern
var isLoaded = false
var isLoadedAnimation_SuperPower = false
var isSeenCouterIntroduction = false

var playernm1 = "Player1"
var playernm2 = "Player2"

var FileSaver = preload("res://global/save_data.gd").new()
#var LableChain = preload("res://scenes/anime/chainLable.tscn")
var NumberScore = preload("res://scenes/anime/NumberScore.tscn")

func _ready():
	$Versus.show()
	$Grid1.hide()
	print("Home ready: isLoaded ", isLoaded)
	characterHide()
	setupInitValues()
	objePattern = preload("res://scripts/PlayerPattern/PlayerPattern.gd").PlayerPattern.new()
	if not GLOBAL.isNetworked:
		var p1String = objePattern.getPatternCharacter(GLOBAL.p1Index)
		var p2String = objePattern.getPatternCharacter(GLOBAL.p2Index)
		loadCharacterFromInput(p1String,p2String)
		startGameAfterVersus()
	else:

		$Control/btnPush.icon = preload("res://art/MainMenu/back_button.png")
		isLoaded = false
		startWaitingOpponent()
		while(true):
			if isLoaded:
				break
			send_PlayerData()
			#print("send player data")
			var t = Timer.new()
			t.set_wait_time(0.5)
			t.set_one_shot(true)
			self.add_child(t)
			t.start()
			yield(t, "timeout")
			t.queue_free()
			
		
func startGameAfterVersus():
	var t = Timer.new()
	t.set_wait_time(6)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free()
	Player1Grid.startPlaying()
	Player2Grid.startPlaying()
	$Versus.hide()
	$Grid1.show()
	charactersShow()
	if GLOBAL.isShowInstruction:
		showGameIntroduction()
	else:
		isSeenCouterIntroduction = true
	#showPowerIntroduction()
	
func loadCharacterFromInput(p1,p2):
	if character_p1 != null:
		return
	character_p1 = characterLoader(p1)#.instance()
	$Control/Player1.add_child(character_p1)
	character_p1.position = $Control/Player2/Position2D.position
	character_p1.position.x -= 49
	#character_p1.position.y += character_p1.get_node("Sprite").offset.y
	character_p1.position.y += 25
	$Control/Player1.myCharacter = character_p1
	$Control/Player1.refreshUI()
	
	character_p2 = characterLoader(p2)#.instance()
	$Control/Player2.add_child(character_p2)
	character_p2.position = $Control/Player1/Position2D.position
	character_p2.position.x += 49
	#character_p2.position.y += character_p2.get_node("Sprite").offset.y
	character_p2.position.y += 25 
	$Control/Player2.myCharacter = character_p2
	$Control/Player2.refreshUI()
	
	$Control/player1Info/VBoxContainer/Name.text = playernm1
	$Control/player2Info/VBoxContainer/Name.text = playernm2
	
	var p1Info = objePattern.getPlayerInfo(GLOBAL.p1Index)
	var p2Info = objePattern.getPlayerInfo(GLOBAL.p2Index)
	
	$Control/player1Info/PlayerImg.texture = load(p1Info["right_img"])
	$Control/player2Info/TextureRect.texture = load(p2Info["left_img"])
	
	pass

#func characterLoader(inputsStr):
#
#	if inputsStr == "dragon":
#		return preload("res://scenes/Characters/Dragon/DragonCharacter.tscn")
#	elif inputsStr == "swardman":
#		return preload("res://scenes/Characters/Swardman/SwardmanCharacter.tscn")
#	elif inputsStr == "robomachine":
#		return preload("res://scenes/Characters/RoboMachine/RoboMachine.tscn")
#	elif inputsStr == "xmachine":
#		return preload("res://scenes/Characters/Xmachine/Xmachine.tscn")
#	elif inputsStr == "knight":
#		return preload("res://scenes/Characters/Knight/Knight.tscn")
#	elif inputsStr == "Sugun":
#		return preload("res://scenes/Characters/Sugun/Sugun.tscn")
#	elif inputsStr == "Golem":
#		return preload("res://scenes/Characters/Golem/Golem.tscn")
#	elif inputsStr == "Ninja":
#		return preload("res://scenes/Characters/Knight/Knight.tscn")
	
func characterLoader(inputsStr):
	if inputsStr == "dragon":
		var character = preload("res://scenes/Character/Dragon/dragon.tscn").instance()
		#character.scale = Vector2(0.6,0.6)
		character.scale = Vector2(0.55,0.55)
		return character
	elif inputsStr == "golem":
		var character = preload("res://scenes/Character/Golem/golem.tscn").instance()
		character.scale = Vector2(0.5,0.5)
		return character
	elif inputsStr == "xmachine":
		var character = preload("res://scenes/Character/Xmachine/Xmachine.tscn").instance()
		character.scale = Vector2(0.5,0.5)
		return character
	elif inputsStr == "robomachine":
		var character = preload("res://scenes/Character/RoboMachine/RoboMachine.tscn").instance()
		#character.scale = Vector2(0.55,0.55)
		character.scale = Vector2(0.45,0.45)
		return character
	elif inputsStr == "knight":
		var character = preload("res://scenes/Character/Knight/Knight.tscn").instance()
		character.scale = Vector2(0.5,0.5)
		return character
	elif inputsStr == "sugun":
		var character = preload("res://scenes/Character/Sugun/Sugun.tscn").instance()
		character.scale = Vector2(0.5,0.5)
		return character
	elif inputsStr == "swordman":
		var character = preload("res://scenes/Character/Swordman/Swordman.tscn").instance()
		#character.scale = Vector2(0.6,0.6)
		character.scale = Vector2(0.5,0.5)
		return character
	elif inputsStr == "ninja":
		var character = preload("res://scenes/Character/Ninja/Ninja.tscn").instance()
		character.scale = Vector2(0.5,0.5)
		return character
	elif inputsStr == "geeky":
		var character = preload("res://scenes/Character/Geeky/geeky.tscn").instance()
		character.scale = Vector2(0.5,0.5)
		return character
	elif inputsStr == "archer":
		var character = preload("res://scenes/Character/Archer/archer.tscn").instance()
		character.scale = Vector2(0.5,0.5)
		return character
	else:
		var character = preload("res://scenes/Character/RoboMachine/RoboMachine.tscn").instance()
		character.scale = Vector2(0.45,0.45)
		return character
		
func charactersShow():
	$Control/Player1.show()
	$Control/Player2.show()
	
func characterHide():
	$Control/Player1.hide()
	$Control/Player2.hide()
		
func setupInitValues():
	if GLOBAL.userData != null:
		if GLOBAL.userData.has("name"):
			playernm1 = GLOBAL.userData["name"]
			if GLOBAL.userData["mute"] == "1":
				$Control/btnSound.icon = preload("res://art/MainMenu/Sound-off.png")
			else:
				$Control/btnSound.icon = preload("res://art/MainMenu/Sound_on.png")
				
	$Grid2/CounterNumberPad/ColorRect.visible = false
	
	p1_selectIndex = GLOBAL.p1Index
	p2_selectIndex = GLOBAL.p2Index
	
	Player1Grid.getCounterPattern(p2_selectIndex)
	Player2Grid.getCounterPattern(p1_selectIndex)
	
	$BgSound.play() #for playing song in Background
	Player2Grid.isMainGrid = 1
	Player2Grid.isMainGrid = 0
	GLOBAL.isPlayerWin = false
	
	if GLOBAL.isNetworked:
		Player2Grid.get_node("lblScore").hide()
		#_configure_TwoPlayers()
		if NetCmd.isPaired:
			NetCmd.player = self
			NetCmd.updateSignal()
			#if GLOBAL.isHost:
			#	sendInitPair()
		else:
			NetCmd.player = null

# Introducation of game
func showGameIntroduction():
	Player1Grid.gmState = GLOBAL.GameState.PAUSE
	Player2Grid.gmState = GLOBAL.GameState.PAUSE
	var popup = preload("res://scenes/popup/Introduction/crashIntro.tscn")
	var obj = popup.instance()
	obj.connect("finish_introduction",self,"finish_introducation")
	obj.connect("skip_introduction",self,"skip_intro")
	add_child(obj)
	characterHide()
	
func finish_introducation():
	Player1Grid.gmState = GLOBAL.GameState.RUNNING
	Player2Grid.gmState = GLOBAL.GameState.RUNNING
	charactersShow()
	gestureIntroduction()
		
func gestureIntroduction():
	$Control/btnPush.disabled = true
	$Control/btnSound.disabled = true
	var t = Timer.new()
	t.set_wait_time(2)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free()
	Player1Grid.gmState = GLOBAL.GameState.PAUSE
	Player2Grid.gmState = GLOBAL.GameState.PAUSE
	var popup = preload("res://scenes/popup/Introduction/gestureIntro.tscn")
	var obj = popup.instance()
	obj.connect("finish_ges_introduction",self,"finish_gesture_introducation")
	obj.connect("skip_introduction",self,"skip_intro")
	add_child(obj)
	$Control/btnPush.disabled = false
	$Control/btnSound.disabled = false
		
func finish_gesture_introducation():
	Player1Grid.gmState = GLOBAL.GameState.RUNNING
	Player2Grid.gmState = GLOBAL.GameState.RUNNING
	var t = Timer.new()
	t.set_wait_time(10)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free()
	showPowerIntroduction()

func showPowerIntroduction():
	Player1Grid.gmState = GLOBAL.GameState.PAUSE
	Player2Grid.gmState = GLOBAL.GameState.PAUSE
	var popup = preload("res://scenes/popup/Introduction/PowerGemIntroducation.tscn")
	var obj = popup.instance()
	obj.connect("finish_power_introduction",self,"_finish_power_introducation")
	obj.connect("skip_introduction",self,"skip_intro")
	add_child(obj)
	
func _finish_power_introducation():
	Player1Grid.gmState = GLOBAL.GameState.RUNNING
	Player2Grid.gmState = GLOBAL.GameState.RUNNING
	GLOBAL.isShowInstruction = false
	
func showCouterGemIntroducation():
	Player1Grid.gmState = GLOBAL.GameState.PAUSE
	Player2Grid.gmState = GLOBAL.GameState.PAUSE
	var popup = preload("res://scenes/popup/Introduction/CouterGemIntroduction.tscn")
	var obj = popup.instance()
	obj.connect("finish_counter_introduction",self,"_finish_counter_introducation")
	#obj.connect("skip_introduction",self,"skip_intro")
	add_child(obj)
	
func _finish_counter_introducation():
	Player1Grid.gmState = GLOBAL.GameState.RUNNING
	Player2Grid.gmState = GLOBAL.GameState.RUNNING
	
func skip_intro():
	Player1Grid.gmState = GLOBAL.GameState.RUNNING
	Player2Grid.gmState = GLOBAL.GameState.RUNNING
	GLOBAL.isShowInstruction = false
	charactersShow()
	
#to show Next pair in Box
func addNextPair(paidData):
	for child in $NextView/NextPair.get_children():
		child.queue_free()
	var gem1 = paidData[0].instance()
	var gem2 = paidData[1].instance()
	var height_width = Player1Grid.offset
	
	$NextView/NextPair.add_child(gem1)
	$NextView/NextPair.add_child(gem2)
	
	gem1.position.y += height_width + 5
	pass

func counterPatternGenret():
	for i in 6:
		GLOBAL.counter_pieces.append([])
		for j in [3,2,1,0]:
			GLOBAL.counter_pieces[i].append(getCounterGem(GLOBAL.playerPattern[j][i]))
		
func getCounterGem(color):
	var cNode
	match color:
		"r":
			cNode = preload("res://scenes/pieces/counter_piece/Red_CounterPiece.tscn")
		"g":
			cNode = preload("res://scenes/pieces/counter_piece/Green_CounterPiece.tscn")
		"y":
			cNode = preload("res://scenes/pieces/counter_piece/Yellow_CounterPiece.tscn")
		"b":
			cNode = preload("res://scenes/pieces/counter_piece/Blue_CounterPiece.tscn")
		_:
			cNode = preload("res://scenes/pieces/counter_piece/Red_CounterPiece.tscn")
	return cNode
		
# Game Push
func _on_btnPush_pressed():
	$ClickSound.play()
	characterHide()
	if GLOBAL.isNetworked:
		Player1Grid.hide() 
		Player2Grid.hide()
		var popUpMenu = preload("res://scenes/TwoPlayer/PauseMenu.tscn").instance()
		add_child(popUpMenu)
		popUpMenu.parentRef = self
	else:
		Player1Grid.gmState = GLOBAL.GameState.PAUSE
		Player2Grid.gmState = GLOBAL.GameState.PAUSE
		Player1Grid.hide()
		Player2Grid.hide()
		var popUpMenu = preload("res://scenes/TwoPlayer/PauseMenu.tscn").instance()
		add_child(popUpMenu)
		popUpMenu.parentRef = self

func resumeGameNow(): 
	$Control/btnPush.icon = preload("res://art/MainMenu/Pause.png") 
	Player1Grid.gmState = GLOBAL.GameState.RUNNING
	Player2Grid.gmState = GLOBAL.GameState.RUNNING
	Player1Grid.show()
	Player2Grid.show()
	charactersShow()
	pass


func _on_btnSound_pressed():
	$ClickSound.play()
	#showPowerIntroduction()
	var t = Timer.new()
	t.set_wait_time(0.5)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	t.connect("timeout",self,"muteSound") 
	yield(t, "timeout")
	
	#$Control/Player1.attack($Control/Player2,3)
	#$Control/Player2.attack($Control/Player1,3)
#	$Control/Player2.runPlayer()
#	$Control/Player2.hitLag()
#	$Control/Player1.defendPunch()
	pass # Replace with function body.
	
func _on_btnSupperPower_pressed():
	var power = $SuperPower.value
	if power == 100:
		$Control/Player1.hitSupperPower(character_p2)
		if GLOBAL.isNetworked: 
			NetCmd.send_supperPower(25)
		else:
			yield(animateValue($Control/player2Info/Health,25),"completed")
		$Control/player1Info/Power.value = 35
		yield(animateValue($SuperPower,power,1.0),"completed")
		isLoadedAnimation_SuperPower = false
		
func animateValue(object,target,tween_duration=0.5):
	var progress = object #$Control/player2Info/Health
	var tween = progress.get_node("Tween")
	tween.interpolate_property(progress,'value',progress.value,progress.value-target,tween_duration,Tween.EASE_IN,Tween.TRANS_SINE)
	tween.start()
	yield(tween,"tween_completed")
	
func muteSound():
	if AudioServer.is_bus_mute(AudioServer.get_bus_index("Master")):
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"),false)
		GLOBAL.userData["mute"] = "0"
		$Control/btnSound.icon = preload("res://art/MainMenu/Sound_on.png")
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"),true)
		GLOBAL.userData["mute"] = "1"
		$Control/btnSound.icon = preload("res://art/MainMenu/Sound-off.png")
	FileSaver._user_data = GLOBAL.userData
	FileSaver.save_data()

# Manage Game Over 
func _on_Player1Grid_GameOver():
	if GLOBAL.isNetworked:
		NetCmd.sendYouWin()
		Player2Grid.gmState = GLOBAL.GameState.NONE
		Player1Grid.gmState = GLOBAL.GameState.NONE
	else:
		_pass_GameoverToUser(Player2Grid)
		GLOBAL.isPlayerWin = false
	pass # Replace with function body.


func _on_Player2Grid_GameOver():
	_pass_GameoverToUser(Player1Grid)
	GLOBAL.isPlayerWin = true
	pass # Replace with function body.


func _pass_GameoverToUser(targetObj):
	targetObj.showYouWin()
	#get_tree().change_scene("res://scenes/popup/Winner.tscn")
	pass

func _on_WaitTimer_timeout():
	if Player1Grid.gmState == GLOBAL.GameState.RUNNING && Player2Grid.gmState == GLOBAL.GameState.RUNNING:
		Player1Grid.DROP_DEFAULT_SPEED += 100 
		Player2Grid.DROP_DEFAULT_SPEED += 100 

func update_P1Score(score):
	$Control/player1Info/VBoxContainer/HBoxContainer/Level.text = score
	if GLOBAL.isNetworked:
		send_P1Score(score)
	
	pass

func update_P2Score(score):
	$Control/player2Info/VBoxContainer/HBoxContainer/Level.text = score
	pass

# Update player health
func _on_Player1Grid_SendCounterGem(count):
	$SuperPower.value += count*4
	$Control/player1Info/Power.value = $SuperPower.value*0.65 + 35
	showCounterNumber(count)
	if $SuperPower.value == 100 && !isLoadedAnimation_SuperPower:
		$SuperPower/AnimationPlayer.play("FullPower")
		isLoadedAnimation_SuperPower = true
		
	if GLOBAL.isNetworked:
		Player1Grid.my_dropTime = OS.get_system_time_msecs()
		var increase_health = 0
		if $Control/player1Info/Power.value == 100:
		#if $SuperPower.value == 100:
			increase_health = count*0.5
			$Control/player1Info/Health.value += increase_health
		var power = $Control/player1Info/Power.value
		NetCmd.sendCounter_GemToplayer(count,increase_health,power)
	else:
		var reduseHealth = count#*GLOBAL.P1_Win_Count
		if GLOBAL.selected_mode == GLOBAL.GameMode.HARD:
			reduseHealth = reduseHealth*0.7
		#$Control/player2Info/Health.value -= reduseHealth
		yield(animateValue($Control/player2Info/Health,reduseHealth),"completed")
		Player2Grid._received_CounterGem(count)
		if $Control/player1Info/Power.value == 100:
			#$Control/player1Info/Health.value += count*0.5
			yield(animateValue($Control/player1Info/Health,-(count*0.5)),"completed")
		if $Control/player2Info/Health.value <= 30:
			Player2Grid._fire_GameOver()
			Player2Grid.gmState = GLOBAL.GameState.NONE
	#print("Helth grid1 : ",$Control/player1Info/Health.value)
	fightCartoon(count)


func _on_Player2Grid_SendCounterGem(count):
	if not GLOBAL.isNetworked:
		var reduceHealth = reducesHelths(count) #count*((GLOBAL.P1_Win_Count+1)*0.5) 
		#$Control/player1Info/Health.value -= reduceHealth
		yield(animateValue($Control/player1Info/Health,reduceHealth),"completed")
		print("Reduse helth : ",reduceHealth," after pHelth :",$Control/player1Info/Health.value)
		Player1Grid._received_CounterGem(count)
		$Control/player2Info/Power.value = $SuperPower.value*0.65 + 35
		if !isSeenCouterIntroduction && !GLOBAL.isShowInstruction:
			isSeenCouterIntroduction = true
			showCouterGemIntroducation()
		
		if $Control/player2Info/Power.value == 100:
			#$Control/player2Info/Health.value += count*0.5
			yield(animateValue($Control/player2Info/Health,-(count*0.5)),"completed")
		if $Control/player1Info/Health.value <= 30:
			Player1Grid._fire_GameOver()
			Player1Grid.gmState = GLOBAL.GameState.NONE
	
	fightCartoon(count,false)
	pass # Replace with function body.

# Cartoon Animation Hit
func fightCartoon(count,isP1=true):
	if character_p2 != null && character_p1 != null:
		if isP1:
			$Control/Player1.attack(character_p2,count)
		else:
			$Control/Player2.attack(character_p1,count)
	pass


func reducesHelths(count):
	# Inscres win game to set difficulty a more reduse helth	
	var helth = count
	match GLOBAL.selected_mode:
		GLOBAL.GameMode.EASY:
			helth = count*((GLOBAL.P1_Win_Count+1)*0.5) 
		GLOBAL.GameMode.NORMAL:
			helth = count + count*0.1+(GLOBAL.P1_Win_Count) 
		GLOBAL.GameMode.HARD:
			helth = count + count*0.09+(GLOBAL.P1_Win_Count)
			helth = helth*0.7
	return helth
	
func showCounterNumber(number):
	#$Grid2/Border/CounterNumberPad.z_index = 3  ## Crash z_index
	$Grid2/CounterNumberPad/ColorRect/Number.text = String(number)
	$Grid2/CounterNumberPad/ColorRect/AnimNumberPad.play("NumberPadAnimation")
	
	
#Detect swipe events on screen
func _on_SwipeDetector_swiped_left():
	Player1Grid.move_piece_left_right(true)

func _on_SwipeDetector_swiped_right():
	Player1Grid.move_piece_left_right(false)

func _on_SwipeDetector_swiped_down(flag):
	Player1Grid.isDropedIn = flag

func _on_SwipeDetector_rotate_tap(flag,_position):
	var rect = $SuperPower.rect_position
	var mRect = $SuperPower.rect_position + ($SuperPower.rect_size * $SuperPower.rect_scale)
	if rect.x < _position.x and rect.y < _position.y and mRect.x > _position.x and mRect.y > _position.y:
		return
		
	if not Player1Grid.onTouchRotation(_position):
		if _position.x < $Grid1.rect_position.x:
			Player1Grid.rotate_piece_(false)
		else:
			Player1Grid.rotate_piece_(true)
#		elif get_viewport().get_visible_rect().size.x - 80 < _position.x:
#			Player1Grid.rotate_piece_(true)


#Assign network ids for grid 1 and 2
func _configure_TwoPlayers():
	if GLOBAL.isHost:
		Player1Grid.set_name("player_grid1")
		Player2Grid.set_name("player_grid2")
		Player1Grid.send_initialData() 
	else:
		Player1Grid.set_name("player_grid2")
		Player2Grid.set_name("player_grid1")
		
	Player1Grid.set_network_master(get_tree().get_network_unique_id())
	Player2Grid.set_network_master(GLOBAL.otherPlayerId) 
	
	if NetCmd.isPaired:
		Player1Grid.set_network_master(int(NetCmd.webSocket.uniqueID))
		Player2Grid.set_network_master(int(NetCmd.targetId))


#send initial pair to remote player
func sendInitPair():
	var t = Timer.new()
	t.set_wait_time(0.5)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free()
	NetCmd.send_initialPair()
	NetCmd.updateSignal()

func startWaitingOpponent():
	var opponentTimer = Timer.new()
	opponentTimer.set_wait_time(1)
	opponentTimer.set_one_shot(true)
	self.add_child(opponentTimer)
	opponentTimer.start()
	yield(opponentTimer, "timeout")
	if not isLoaded:
		$WaitingOpponent.show()
		$WaitingOpponent.connect("go_home",self,"_on_gotoHome")

#	if not isLoaded:
#		var alert = preload("res://scenes/popup/MessagePopup.tscn").instance()
#		alert.setMessage("Connection with opponent lost")
#		self.add_child(alert)
#		alert.show()
#		print("Not loaded opponet")
func receive_stop_opponent_waiting():
	print("Stop waiting")
	$WaitingOpponent/CanvasLayer/Title.text = "Connection with oppponent lost"
	$WaitingOpponent/CanvasLayer/lblNotFoundMsg.show()
	
func _on_gotoHome():
	GLOBAL.player1Score = 0
	GLOBAL.P1_Win_Count = 0
	GLOBAL.AI_Play_Index = []
	GLOBAL.pairManager = null
	NetCmd._disconnect()		
	get_tree().change_scene("res://scenes/MainMenu/LevelMockup.tscn")


	
func startGameAfter(time):
	var t = Timer.new()
	t.set_wait_time(time)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free()
	Player1Grid.spaw_pair_from_top()
	Player2Grid.playerType = GLOBAL.PlayerMode.NONE
	
func refresh_Pair():
	Player1Grid.showNextPair()
	Player2Grid.showNextPair()

func received_counterGem_remote(counts):
	Player1Grid._received_CounterGem(counts)

func send_counter_gemToRemoteWindow(array):
	NetCmd.sendCounterGem_remotWindow(array)

func drop_gemInPlayer2Widnow(array):
	Player2Grid.drop_counterGemIn_remoteWindow(array)

func spawn_pairInPlayer2Window():
	Player2Grid.spaw_pair_from_top()

func receive_counterFrom(counts,time,health,power):
	Player1Grid.c_dropTime = time
	Player1Grid._received_CounterGem(int(counts))
	#$Control/player1Info/Health.value -= counts
	#$Control/player2Info/Health.value += health
	yield(animateValue($Control/player1Info/Health,counts),"completed")
	yield(animateValue($Control/player2Info/Health,-(health)),"completed")
	$Control/player2Info/Power.value = power #$SuperPower.value*0.65 + 35
	send_healthData($Control/player1Info/Health.value)
	if $Control/player1Info/Health.value <= 30:
		Player1Grid._fire_GameOver()
		Player1Grid.gmState = GLOBAL.GameState.NONE
	
func show_youWin():
	GLOBAL.isPlayerWin = true
	Player1Grid.showYouWin()
	Player2Grid.gmState = GLOBAL.GameState.NONE
	Player1Grid.gmState = GLOBAL.GameState.NONE
	
func receive_opponent_lose():
	Player1Grid.gmState = GLOBAL.GameState.PAUSE
	characterHide()
	Player1Grid.hide() 
	Player2Grid.hide()
	if self.has_node("MessagePopup"):
		print("alert node exits")
		return

	else:
		print("alert node not exits")
	var alert = preload("res://scenes/popup/MessagePopup.tscn").instance()
	alert.setMessage("Connection with opponent lost")
	alert.connect("close_popup",self,"_on_gotoHome")
	self.add_child(alert)
	alert.show()
	print("Not loaded opponet")


func sendLastPairData(data):
	NetCmd.send_lastPairDrop(data)
	$SwipeDetector.z_index = 10
	pass

func add_lastPairInRmtWindow(data):
	Player2Grid.putGemIn(data)
	$SwipeDetector.z_index = 10
	pass

func send_PlayerData():
	var data = {"player_index":GLOBAL.p1Index,"player_name":playernm1}
	NetCmd.send_characterData(data)
	pass

func send_P1Score(score):
	NetCmd.send_scoreData(str(score))

func update_scoreInRemoteWindow(score):
	update_P2Score(score)

func send_healthData(value):
	NetCmd.send_healthData(value)
	pass

func update_healthInRemoteWindow(value):
	#$Control/player2Info/Health.value = value 
	var newVal = $Control/player2Info/Health.value - value 
	yield(animateValue($Control/player2Info/Health,newVal),"completed")
	pass

func receive_supperPower(value):
	#$Control/player1Info/Health.value -= value
	yield(animateValue($Control/player1Info/Health,value),"completed")
	send_healthData($Control/player1Info/Health.value)
	pass


var isPlayDataGet = false
func remote_playerLoad(data):
	playernm2 = data["player_name"]
	isLoaded = true
	GLOBAL.p2Index = int(data["player_index"])
	var p1String = objePattern.getPatternCharacter(GLOBAL.p1Index)
	var p2String = objePattern.getPatternCharacter(GLOBAL.p2Index)
	loadCharacterFromInput(p1String,p2String)
	
	Player1Grid.getCounterPattern(GLOBAL.p2Index)
	Player2Grid.getCounterPattern(GLOBAL.p1Index)
	
	if not isPlayDataGet:
		isPlayDataGet = true
		$WaitingOpponent.hide()
		$Versus/Container.hide()
		$Versus.startAnimation()
		
		var t = Timer.new()
		t.set_wait_time(5)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
		t.queue_free()
		$Versus.hide()
		$Grid1.show()
		charactersShow()
		if GLOBAL.isHost:
			NetCmd.send_startGm()
			sendInitPair()
	pass

#Signal from grid: Show power gem destory point
func _on_Player1Grid_powerGemScore(score,position):
	var point = score/10
	#var pos = $Grid1.get_position_in_parent()
	print("Power gem score home ",point, position)
	var objScore = NumberScore.instance()
	#objScore.z_index = 3
	#objScore.get_node("Label").text = str(point)
	objScore.get_node("Label").text = String(point)
	objScore.position = position
	Player1Grid.add_child(objScore)
	
	#add_child(objScore)
	pass # Replace with function body.
