extends "res://scripts/main/Grid.gd"

var c_dropTime
var my_dropTime

var arr_indicators = ["CAUTION","WARNING","DANGER"]


func _ready():
	._ready()
	score = GLOBAL.player1Score
	_update_score(0)
	get_parent().get_parent().update_P1Score($lblScore.text)
	playerType = GLOBAL.PlayerMode.PLAYER
	isCanPlaySound = true
	showNextPair()

func _draw():
	for i in width+1:
		var sPos = gemEngine.grid_to_pixel(i,0)
#		if i >= 4:
#			sPos.x = sPos.x + 2.8
		sPos.x = sPos.x - 28
		sPos.y = sPos.y + 32
		var ePos = gemEngine.grid_to_pixel(i,12)
		#ePos.x = ePos.x - 28
		ePos.x = sPos.x
		draw_line(sPos,ePos,Color(16/255, 60/255, 66/255,0.5),0.1,false)
		
func spaw_pair_from_top(isP1=true):
	if not gemEngine.isGemRemoved:
		_update_score(10)
	
	.spaw_pair_from_top(true)
	.showNextPair(true)
	isNetcGemSend = false
	pre_sender = 0
	get_parent().get_parent().update_P1Score($lblScore.text)

func _dropNewPair_Timer_Out():
	._dropNewPair_Timer_Out()
	if isCGemToFall:
		#Drop Counter Gems:
		isCGemToFall = false
		if isNetcGemSend && GLOBAL.isNetworked:
			isNetcGemSend = false
			if my_dropTime > c_dropTime:
				#If im late to destroy gem then drop at my side
				var halfGems = int(pre_sender/2)
				var extra = counterGemHolder%2
				counterGemHolder = counterGemHolder - halfGems + extra
				$lblcounterGem.text = str(counterGemHolder)
			else:
				var diff = pre_sender*2
				if diff >= counterGemHolder:
					counterGemHolder = 0
				else:
					counterGemHolder = counterGemHolder - pre_sender%2
				$lblcounterGem.text = str(counterGemHolder)
			c_dropTime = 0.0
			my_dropTime = 0.0
			pre_sender = 0
		_makeCounterGem()
		$Warning/lbl_warning.text = ""
		$GemCount/lbl_counter_count.text = ""
	else:
		if checkColumnDrop():
			spaw_pair_from_top()

func showYouWin():
	GLOBAL.isWin = true
	.showYouWin()
	#$Winner.position.x = self.position.x/2
	GLOBAL.player1Score = score
	
	if GLOBAL.selected_mode == 2:
		GLOBAL.P1_Win_Round += 1
		if GLOBAL.P1_Win_Round == 2:
			GLOBAL.P1_Win_Count += 1
			GLOBAL.P1_lose_Round = 0
	else:
		GLOBAL.P1_Win_Count += 1
		
	#get_tree().change_scene("res://scenes/main/ShowGameResult.tscn")
	get_tree().change_scene("res://scenes/popup/Winner.tscn")
	#var obj = "res://scenes/popup/Winner.tscn"
	
func _fire_GameOver():
	#._fire_GameOver()
	emit_signal("GameOver")
	for j in height:
		for i in width:
			if all_pieces[i][j] != null:
				all_pieces[i][j].grayScale()
				
				for item in all_pieces[i][j].get_children():
					if "PowerGemBase" in item.name:
						item.removeGlow()
						break
		var t = Timer.new()
		t.set_wait_time(0.05)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
		t.queue_free()
	# For hard level to managed round.
	if GLOBAL.selected_mode == 2 && not GLOBAL.isNetworked:
		GLOBAL.P1_lose_Round += 1
		if GLOBAL.P1_lose_Round == 2:
			GLOBAL.player1Score = 0
	else:
		GLOBAL.player1Score = 0
	GLOBAL.isWin = false
	get_tree().change_scene("res://scenes/popup/Winner.tscn")
	

func get_piece_FixPosition():
	.get_piece_FixPosition()
	
	if GLOBAL.isNetworked :
		var arrayData = [p1_data,p2_data]
		var home = self.get_parent().get_parent()
		if home != null && home.name == "Home":
			home.sendLastPairData(arrayData)
	#else:
#		var playSong = SoundMrg.instance()
#		add_child(playSong)
#		playSong.loadSoundWithID(1)
		pass
			
func _create_power_gem_At(_position,_size,_color):
	._create_power_gem_At(_position,_size,_color)
	var playSong = SoundMrg.instance()
	add_child(playSong)
	playSong.loadSoundWithID(2)

func _received_CounterGem(count):
	._received_CounterGem(count)
	$Warning/lbl_warning.modulate = Color("ffffff")
	if counterGemHolder < 11:
		$Warning/lbl_warning.text = arr_indicators[0]
		$Warning/lbl_warning.modulate = Color("12ece7")
	elif counterGemHolder < 31:
		$Warning/lbl_warning.text = arr_indicators[1]
		$Warning/lbl_warning.modulate = Color("12ece7")
	elif counterGemHolder >= 31:
		$Warning/lbl_warning.text = arr_indicators[2]
		$Warning/lbl_warning.modulate = Color("f10707")
	
	
	$GemCount/lbl_counter_count.text = str(counterGemHolder)
	if counterGemHolder == 0:
		$Warning/lbl_warning.text = ""
		$GemCount/lbl_counter_count.text = ""

func _gem_crashed_signal(counts):
	._gem_crashed_signal(counts)
	if counterGemHolder == 0:
		$Warning/lbl_warning.text = ""
		$GemCount/lbl_counter_count.text = ""

func getCounterPattern(index):
	counterPatternGenret(index)
	pass
	
