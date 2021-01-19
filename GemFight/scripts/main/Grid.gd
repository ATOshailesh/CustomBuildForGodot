extends Node2D

signal GameOver
signal SendCounterGem
signal CounterFromRemote
signal powerGemScore

# Grid Variables
export (int) var width;
export (int) var height;
export (int) var x_start;
export (int) var y_start;
export (int) var offset;

onready var effectTween = get_node("effect")
onready var SoundMrg = preload("res://scenes/Sounds/SoundEngine.tscn")

var all_pieces = [];

# State : Running, Gameover,NotRunning
var gmState

# Mode : Easy,Normal,Hard
var gmMode

#Game Play Mode : Single or Multi
var gmPlayMode = GLOBAL.GamePlayer.SINGLE

# Drop Current Gem Quickly
var isDropedIn = false

#Check Drop Pair isn't breaked
var isCurentPairBreak = false

#Pair Object holder
var curent_obje1
var curent_obje2


var PlaceHoldeNode = preload("res://scenes/pieces/Placeholder.tscn")
#Placeholder Pair
var placehld_black
var placehld_white

# Drop Delta for faster Fall
var FREE_DROP_DELTA = 0.3

# Default Pair Drop speed
var DROP_DEFAULT_SPEED = 70

# TO CHeck both pieces are droped
var dropCount = 0

#to Prevent Load multiple pieces in scene
var newPieceLoaded = false

#Check Rotation is in progress
var isRotateIn = false

#Check Is Diamond Gem Droped
var diamonGemIn

#Gem Deleting Animation
var BoomAnime = preload("res://scenes/anime/Boom.tscn")

#Show Chain lable
var LableChain = preload("res://scenes/anime/chainLable.tscn")
var lblNode

#Player type : User,PC/AI or User2
var playerType
var playerNo = 1

#Check AI called after Pair visible in scene
var isAICalled = false

# Timer handle auto drop pair duration
var timerPair

# For debug : toggle Auto Drop signal
var ignoreSignal = true

# CountHolder to Dropped in Grid
var counterGemHolder = 0


var ObjeGemEngine = preload("res://scripts/Engine/GemEngine.gd")
var gemEngine
var pairManager


var scoreManager 
#Manage Player scrore
var score = 0
var extraGem
var isMainGrid = 0

#use to pass pair data to remote player
var p1_data 
var p2_data 
var isNetcGemSend
var pre_sender = 0


#Disable sound for remote grid
var isCanPlaySound = false


var counterPatternHolder = [] 
var counterPieceHolder = []




func _ready():
	gmState = GLOBAL.GameState.RUNNING
	if GLOBAL.selected_mode == 0:
		gmMode = GLOBAL.GameMode.EASY
		
	elif GLOBAL.selected_mode == 1:
		gmMode = GLOBAL.GameMode.NORMAL
		DROP_DEFAULT_SPEED = 150
		
	elif GLOBAL.selected_mode == 2:
		gmMode = GLOBAL.GameMode.HARD
		DROP_DEFAULT_SPEED = 160 # 180
	
	
	all_pieces = make_2d_array()
	gemEngine = ObjeGemEngine.GemEngine.new(all_pieces,height,width,x_start,y_start,offset)
	gemEngine.connect("boomAnime",self,"_on_piece_removeAt")
	gemEngine.connect("dropAnime",self,"dropAnimation_piece")
	gemEngine.connect("timeAnime",self,"_call_time_delay")
	gemEngine.connect("showChain",self,"showChainLable")
	gemEngine.connect("_newPair_Emit",self,"_dropNewPair")
	gemEngine.connect("_gem_crashed",self,"_gem_crashed_signal")
	gemEngine.connect("wait_to_normal",self,"_counter_to_normal")
	gemEngine.connect("create_power_gem",self,"_create_power_gem_At")
	gemEngine.connect("_show_score",self,"_update_score")
	gemEngine.connect("_show_power_gem_score",self,"_get_powerGemScore")
	
	if GLOBAL.pairManager == null:
		print("Set new PairManager")
		GLOBAL.pairManager = ObjeGemEngine.PairEngine.new()
		pairManager = GLOBAL.pairManager
	else:
		pairManager = GLOBAL.pairManager
	
	if not GLOBAL.isNetworked:
		scoreManager =  ObjeGemEngine.ScroreManager.new()
		gemEngine.scrManager = scoreManager
		#_dropNewPair()
	else:
		scoreManager =  ObjeGemEngine.ScroreManager.new()
		gemEngine.scrManager = scoreManager


func startPlaying():
	_dropNewPair()


# create grid empty array :
func make_2d_array():
	var array = [];
	for i in width:
		array.append([]);
		for j in height:
			array[i].append(null);
	return array;
	

func _physics_process(delta):
	if gmState == GLOBAL.GameState.PAUSE:
		return
	if gmState == GLOBAL.GameState.RUNNING:
		var factDelta = delta
		if isDropedIn:
			factDelta += 0.5
		drop_pair_to_End(factDelta)
		
		if curent_obje1 == null && curent_obje2 == null && proccessCGem:
			_dropCounterGem()
		
	pass

var swipe_start = null
var minimum_drag = 100
var islock = false

func _input(event):
	if gmState == GLOBAL.GameState.PAUSE:
		return
	
	if GLOBAL.isNetworked:
		if playerType == GLOBAL.PlayerMode.NONE:
			return
#	elif GLOBAL.isNetworked:
#		if not is_network_master():
#			return
	
	var margin = 115.0
	if gmState == GLOBAL.GameState.RUNNING:
		if event.is_action_pressed("ui_accept"):
			pass
		elif event.is_action_released("spawn_pair"):
#			if GLOBAL.isNetworked:
#				fire_new_pair()
#			else:
#				if not newPieceLoaded :
#					newPieceLoaded = true
#					spaw_pair_from_top()
			pass
		if playerType != GLOBAL.PlayerMode.AI:
			if playerNo == 1:
				if event.is_action_pressed("ui_touch"):
#					var pos = gemEngine.pixel_to_grid(get_global_mouse_position().x,get_global_mouse_position().y)
#					addPieceAtPos(pos)
					pass
				elif event.is_action_pressed("move_left"):
					if curent_obje2 != null and curent_obje1 != null :
						move_piece_left_right(true)
				elif event.is_action_pressed("move_right"):
					if curent_obje2 != null and curent_obje1 != null :
						move_piece_left_right(false)
				elif event.is_action_pressed("rotate_cv"):
					if curent_obje2 != null and curent_obje1 != null :
						isRotateIn = true
						rotate_piece_(true)
				elif event.is_action_pressed("rotate_ccv"):
					if curent_obje2 != null and curent_obje1 != null :
						rotate_piece_(false)
				elif event.is_action_pressed("drop"):
					isDropedIn = true
					#if GLOBAL.isNetworked:
					#	if is_network_master():
					#		rpc_unreliable("_drop_piece_remote",isDropedIn)
				elif event.is_action_released("drop"):
					isDropedIn = false
					#if GLOBAL.isNetworked:
					#	if is_network_master():
					#		rpc_unreliable("_drop_piece_remote",isDropedIn)
			elif playerNo == 2:
				if event.is_action_pressed("p2_move_left"):
					if curent_obje2 != null and curent_obje1 != null :
						move_piece_left_right(true)
				elif event.is_action_pressed("p2_move_right"):
					if curent_obje2 != null and curent_obje1 != null :
						move_piece_left_right(false)
				elif event.is_action_pressed("p2_rotate_cv"):
					if curent_obje2 != null and curent_obje1 != null :
						isRotateIn = true
						rotate_piece_(true)
				elif event.is_action_pressed("p2_rotate_ccv"):
					if curent_obje2 != null and curent_obje1 != null :
						rotate_piece_(false)
				elif event.is_action_pressed("p2_drop"):
					isDropedIn = true
				elif event.is_action_released("p2_drop"):
					isDropedIn = false


func addPieceAtPos(posGird):
	
	if posGird.x >= 0 and posGird.x < width and posGird.y >= 0 and posGird.y < height:
		var cNode
		if GLOBAL.isCrashOn == "n":
			if GLOBAL.selectColor == "r":
				cNode = GLOBAL.possible_pieces[0].instance()
			elif GLOBAL.selectColor == "g":
				cNode = GLOBAL.possible_pieces[1].instance()
			elif GLOBAL.selectColor == "y":
				cNode = GLOBAL.possible_pieces[3].instance()
			elif GLOBAL.selectColor == "b":
				cNode = GLOBAL.possible_pieces[2].instance()
		elif GLOBAL.isCrashOn == "c":
			if GLOBAL.selectColor == "r":
				cNode = GLOBAL.possible_pieces[4].instance()
			elif GLOBAL.selectColor == "g":
				cNode = GLOBAL.possible_pieces[5].instance()
			elif GLOBAL.selectColor == "y":
				cNode = GLOBAL.possible_pieces[7].instance()
			elif GLOBAL.selectColor == "b":
				cNode = GLOBAL.possible_pieces[6].instance()
		elif GLOBAL.isCrashOn == "co":
			cNode = getCounterGem(GLOBAL.selectColor).instance()

		cNode.position = gemEngine.grid_to_pixel(posGird.x,posGird.y)
		cNode.myPos = Vector2(posGird.x,posGird.y)
		all_pieces[posGird.x][posGird.y] = cNode
		add_child(cNode)
		pass


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


var isPiece1Up = false

func getGemData(gem):
	#NORMAL,CRASH,COUNTER,DIAMOND
	var colr = ""
	var data = {}
	if gem.gemType == GLOBAL.GemTypes.NORMAL :
		data["t"] = "n"
	elif gem.gemType == GLOBAL.GemTypes.CRASH:
		data["t"] = "c"
	elif gem.gemType == GLOBAL.GemTypes.DIAMOND:
		data["t"] = "d"
	match gem.color:
		"pink":
			colr = "r"
		"green":
			colr = "g"
		"yellow":
			colr = "y"
		"blue":
			colr = "b"
		_:
			colr = "r"
	data["cc"] = colr
	return data

func putGemIn(arrData):
	for item in arrData:
		var type = item["t"]
		var color = item["cc"]
		var sss = item["p"]
		var pos = Vector2(item["p"][0],item["p"][1])
		var gridPos = gemEngine.pixel_to_grid(pos.x,pos.y)
		if gridPos.y < 13 :
			var pice = GLOBAL.get_gemFromData(type,color).instance()
			add_child(pice)
			if type == "d":
				diamonGemIn = pice
			pice.position = pos 
			all_pieces[gridPos.x][gridPos.y] = pice
	get_piece_FixPosition()


#Default drop animation with 
func drop_pair_to_End(factor):
	if not isCurentPairBreak:
		# This condition for AI/PC user only
		if not isAICalled && curent_obje1 != null && playerType == GLOBAL.PlayerMode.AI :
			if curent_obje2.position.y >= gemEngine.grid_to_pixel(0,13).y + 20:
				call_AI_func()
		#Piece1 is At Bottom Side
		if curent_obje1 != null:
			if not manage_piece_position(curent_obje1,factor):
				p1_data = getGemData(curent_obje1)
				p1_data["p"] = [curent_obje1.position.x,curent_obje1.position.y]
				curent_obje1 = null
				isCurentPairBreak = true
				dropCount = dropCount + 1
				placehld_white.queue_free()
				placehld_white = null
		if curent_obje2 != null:
			if not manage_piece_position(curent_obje2,factor):
				var pos = gemEngine.pixel_to_grid(curent_obje2.position.x,curent_obje2.position.y)
				if pos.y >= 13:
					extraGem = curent_obje2
				p2_data = getGemData(curent_obje2)
				p2_data["p"] = [curent_obje2.position.x,curent_obje2.position.y]
				
				curent_obje2 = null
				isCurentPairBreak = true
				placehld_black.queue_free()
				placehld_black = null
				dropCount = dropCount + 1
	else :
		if curent_obje2 != null:
			if not manage_piece_position(curent_obje2,FREE_DROP_DELTA):
				p2_data = getGemData(curent_obje2)
				p2_data["p"] = [curent_obje2.position.x,curent_obje2.position.y]
				curent_obje2 = null
				dropCount = dropCount + 1
				if placehld_black != null:
					placehld_black.queue_free()
					placehld_black = null
		
		if curent_obje1 != null:
			if not manage_piece_position(curent_obje1,FREE_DROP_DELTA):
				p1_data = getGemData(curent_obje1)
				p1_data["p"] = [curent_obje1.position.x,curent_obje1.position.y]
				curent_obje1 = null
				dropCount = dropCount + 1
				if placehld_white != null:
					placehld_white.queue_free()
					placehld_white = null
	
	if dropCount == 2:
		get_piece_FixPosition()

#Drop pic at bottom if find empty space
func manage_piece_position(myGem,factor):
	var gridPos = gemEngine.pixel_to_grid(myGem.position.x,myGem.position.y)
	var targetPosY = gemEngine.grid_to_pixel(0,0).y
	for i in gridPos.y:
		if all_pieces[gridPos.x][i] != null && i < 13:
			var margin = 0
			if gmMode == GLOBAL.GameMode.HARD:
				margin = 5
			elif gmMode == GLOBAL.GameMode.NORMAL:
				margin = 5
			if isDropedIn:
				margin = 10
			targetPosY = gemEngine.grid_to_pixel(gridPos.x,i+1).y - margin
	
	
	if myGem.position.y+5 < targetPosY:
		myGem.position.y = myGem.position.y + (factor * DROP_DEFAULT_SPEED)
	else:
		var gridPos2 = gemEngine.pixel_to_grid(myGem.position.x,targetPosY)
		if gridPos2.y >= height:
			return false
		
		if all_pieces[gridPos2.x][gridPos2.y] != null:
			var nYpos = gridPos2.y + 1
			
			while(nYpos <= height):
				if all_pieces[gridPos2.x][nYpos] == null:
					gridPos2.y = nYpos
					break
				nYpos += 1
		
		#Prevent gem to place at same position :)
		if all_pieces[gridPos2.x][gridPos2.y] != null :
			if gridPos2.y < 12:
				if all_pieces[gridPos2.x][gridPos2.y+1] == null:
					all_pieces[gridPos2.x][gridPos2.y+1] = myGem
					myGem.position = gemEngine.grid_to_pixel(gridPos2.x,gridPos2.y+1)
					return false
			
		all_pieces[gridPos2.x][gridPos2.y] = myGem
		myGem.position = gemEngine.grid_to_pixel(gridPos2.x,gridPos2.y)
		return false
		
	return true

func getEmptuPosFrom(rowNumber,hightNum):
	var target = 0
	for i in range(hightNum,-1,-1):
		if i < height:
			if all_pieces[rowNumber][i] != null:
				target = i+1
				break
	return gemEngine.grid_to_pixel(rowNumber,target)

func setPlaceHolderPosition():
	#Check which piece is above
		if  curent_obje2 != null && curent_obje1 != null :
			var p1Pos = gemEngine.pixel_to_grid(curent_obje1.position.x,curent_obje1.position.y)
			placehld_white.position = getEmptuPosFrom(p1Pos.x,p1Pos.y)
			var p2Pos = gemEngine.pixel_to_grid(curent_obje2.position.x,curent_obje2.position.y)
			placehld_black.position = getEmptuPosFrom(p2Pos.x,p2Pos.y)
			if is_check_pairInSameVLine():
				#check Whice piece is above
				if check_first_piece_side(true):
					#p1 is below
					placehld_black.position.y  = placehld_black.position.y - offset
				else:
					#p2 is below
					placehld_white.position.y  = placehld_white.position.y - offset


func showNextPair(isP1=false):
	
#	for child in $NextPair.get_children():
#		child.queue_free()
	
	var nxtPair = pairManager.getNextPair(isP1)
	if isP1 == true:
		var home = self.get_parent().get_parent()
		if home != null && home.name == "Home":
			home.addNextPair(nxtPair)
#	var gem1 = nxtPair[0].instance()
#	var gem2 = nxtPair[1].instance()
#	var height_width = offset
#	if gem1.get_node("Sprite").texture != null:
#		height_width = gem1.get_node("Sprite").texture.get_size().y/2
#	elif gem2.get_node("Sprite").texture != null:
#		height_width = gem2.get_node("Sprite").texture.get_size().y/2
	
#	$NextPair.add_child(gem1)
#	$NextPair.add_child(gem2)
#	gem1.position.y += height_width

# add New pair in scene for drop
func spaw_pair_from_top(isP1=true):
	p1_data = {}
	p2_data = {}
	
	islock = false
	extraGem = null
	diamonGemIn = null
	GLOBAL.possible_pieces[4]
	var newPair = pairManager.provide_new_pair(isP1)
	#var ppp = GLOBAL.possible_pieces[2]
	curent_obje1 = newPair[0].instance() # newPair[0].instance() # ppp.instance() #
	curent_obje2 = newPair[1].instance() # newPair[1].instance() # ppp.instance() #
	
	curent_obje1.z_index = 0
	curent_obje2.z_index = 0
	add_child(curent_obje1)
	add_child(curent_obje2)
	curent_obje1.position = gemEngine.grid_to_pixel(3,12)
	curent_obje2.position = gemEngine.grid_to_pixel(3,13)
	isCurentPairBreak = false
	isDropedIn = false
	
	if curent_obje1.gemType == GLOBAL.GemTypes.DIAMOND:
		diamonGemIn = curent_obje1
	elif curent_obje2.gemType == GLOBAL.GemTypes.DIAMOND:
		diamonGemIn = curent_obje2
	
	#Reset counterGemHolder for new Gems
	counterGemHolder = 0
	$lblcounterGem.text = ""
	
	placehld_black = PlaceHoldeNode.instance()
	add_child(placehld_black)
	placehld_black.z_index = -1
	placehld_black.position  = getEmptuPosFrom(3,12)
	placehld_black.position.y -= offset

	
	placehld_white = PlaceHoldeNode.instance()
	placehld_white.setTexture(false)
	add_child(placehld_white)
	placehld_white.z_index = -1
	placehld_white.position  = getEmptuPosFrom(3,12)

var extraLock = false

func _fixed_extraGem():
	if extraGem == null:
		print("ExtraGem get null")
		return
	var pos = extraGem.position
	var posGrid = gemEngine.pixel_to_grid(extraGem.position.x,extraGem.position.y)
	var maxY = height-1
	var c = 0
	while(maxY != -1):
		if all_pieces[posGrid.x][maxY] != null:
			break
		maxY -= 1
	maxY += 1
	if maxY < height:
		var newPosGrid = Vector2(posGrid.x,maxY)
		var newPos = gemEngine.grid_to_pixel(newPosGrid.x,newPosGrid.y)
		if isCellEmpty(newPosGrid.x,newPosGrid.y):
			all_pieces[newPosGrid.x][newPosGrid.y] = extraGem
			dropAnimation_piece(extraGem,newPos)
			extraGem.myPos = newPosGrid
			var t = Timer.new()
			t.set_wait_time(0.25)
			t.set_one_shot(true)
			self.add_child(t)
			t.start()
			t.connect("timeout",self,"_on_rearrange_checked") 
			yield(t, "timeout")
			t.queue_free()
			extraGem = null
			#all_pieces[newPosGrid.x][newPosGrid.y].position = newPos
			extraLock = false
			gemEngine.find_matrix()
		

func playMovedSound():
	if playerType == GLOBAL.PlayerMode.PLAYER:
		var playSong = SoundMrg.instance()
		add_child(playSong)
		playSong.loadSoundWithID(3)

#Moving Opearation
func move_piece_left_right(isLeft):	
	if gmState == GLOBAL.GameState.PAUSE:
		return
	#check first obje1 is left/right side
	if GLOBAL.isNetworked:
		if isMainGrid == 1:
			NetCmd.move_pieces(isLeft)
	
	if curent_obje2 == null:
		return
	var height_width = offset
	
	if is_check_pairInSameVLine():
		var gridColumn = get_piece_grid(curent_obje1)
		var gridColumn2 = get_piece_grid(curent_obje2)
		
		if isLeft:
			if gridColumn.x != 0:
				var newY = gemEngine.grid_to_pixel(gridColumn.x-1,gridColumn.y).x
				if isCellEmpty(gridColumn.x-1,gridColumn.y): 
					if gridColumn2.y <= 12:
						#check player in not AI/PC
						if playerType == GLOBAL.PlayerMode.PLAYER:
							if isCellEmpty(gridColumn2.x-1,gridColumn2.y):
								curent_obje1.position.x = newY
								curent_obje2.position.x = newY
								playMovedSound()
						else:
							if isCellEmpty(gridColumn2.x-1,gridColumn2.y):
								curent_obje1.position.x = newY
								curent_obje2.position.x = newY
								playMovedSound()
					else:
						#check player in not AI/PC
						if playerType == GLOBAL.PlayerMode.PLAYER:
							if isCellEmpty(gridColumn2.x-1,gridColumn2.y):
								curent_obje1.position.x = newY
								curent_obje2.position.x = newY
								playMovedSound()
						else:
							curent_obje1.position.x = newY
							curent_obje2.position.x = newY
							playMovedSound()
					
		else:
			if gridColumn.x != width-1:
				var newY = gemEngine.grid_to_pixel(gridColumn.x+1,gridColumn.y).x
				if isCellEmpty(gridColumn.x+1,gridColumn.y): #&& isCellEmpty(gridColumn2.x+1,gridColumn2.y):
					if gridColumn2.y <= 12:
						#check player in not AI/PC
						if playerType == GLOBAL.PlayerMode.PLAYER:
							if isCellEmpty(gridColumn2.x+1,gridColumn2.y):
								curent_obje1.position.x = newY
								curent_obje2.position.x = newY
								playMovedSound()
						else:
							if isCellEmpty(gridColumn2.x+1,gridColumn2.y):
								curent_obje1.position.x = newY
								curent_obje2.position.x = newY
								playMovedSound()
					else:
						#check player in not AI/PC
						if playerType == GLOBAL.PlayerMode.PLAYER:
							if isCellEmpty(gridColumn2.x-1,gridColumn2.y):
								curent_obje1.position.x = newY
								curent_obje2.position.x = newY
								playMovedSound()
						else:
							curent_obje1.position.x = newY
							curent_obje2.position.x = newY
							playMovedSound()
	else:
		var check1PieceXSide = check_first_piece_side(false)
		if check1PieceXSide:
			if isLeft:
				var gridColumn = get_piece_grid(curent_obje1)
				if gridColumn.x != 0:
					var newY = gemEngine.grid_to_pixel(gridColumn.x-1,gridColumn.y).x
					if isCellEmpty(gridColumn.x-1,gridColumn.y):
						curent_obje1.position.x = newY
						curent_obje2.position.x = newY + height_width
						playMovedSound()
			else:
				var gridColumn = get_piece_grid(curent_obje2)
				if gridColumn.x != 5:
					var newY = gemEngine.grid_to_pixel(gridColumn.x+1,gridColumn.y).x
					if isCellEmpty(gridColumn.x+1,gridColumn.y):
						curent_obje1.position.x = newY - height_width
						curent_obje2.position.x = newY
						playMovedSound()
		else:
			if isLeft:
				var gridColumn = get_piece_grid(curent_obje2)
				if gridColumn.x != 0:
					var newY = gemEngine.grid_to_pixel(gridColumn.x-1,gridColumn.y).x
					if isCellEmpty(gridColumn.x-1,gridColumn.y):
						curent_obje1.position.x = newY + height_width
						curent_obje2.position.x = newY
						playMovedSound()
			else:
				var gridColumn = get_piece_grid(curent_obje1)
				if gridColumn.x != 5:
					var newY = gemEngine.grid_to_pixel(gridColumn.x+1,gridColumn.y).x
					if isCellEmpty(gridColumn.x+1,gridColumn.y):
						curent_obje1.position.x = newY 
						curent_obje2.position.x = newY - height_width
						playMovedSound()
	setPlaceHolderPosition()

#Rotate Pair
func rotate_piece_(isClockWise):
	if gmState == GLOBAL.GameState.PAUSE:
		return
	if GLOBAL.isNetworked:
		NetCmd.rotate_pieces(isClockWise)
		#if (is_network_master()):
			#rpc_unreliable("_rotate_remote",isClockWise)
	
	if curent_obje1 == null || curent_obje2 == null:
		return
	
	var p1grid = get_piece_grid(curent_obje1)
	var p2grid = get_piece_grid(curent_obje2)
	var height_width = offset#64.0
#	if curent_obje2.get_node("Sprite").texture != null:
#		height_width = curent_obje2.get_node("Sprite").texture.get_size().y/2
#	elif curent_obje1.get_node("Sprite").texture != null:
#		height_width = curent_obje1.get_node("Sprite").texture.get_size().y/2
	var check1PieceXSide = check_first_piece_side(false)
	var check1PieceYSide = check_first_piece_side(true)
	
	if is_check_pairInSameVLine():
		if check1PieceYSide:
			if isClockWise:
				if p2grid.x == 0:
					var newPoint = Vector2(curent_obje1.position.x+height_width,curent_obje1.position.y)
					var gridPos = gemEngine.pixel_to_grid(newPoint.x,newPoint.y)
					if isCellEmpty(gridPos.x,gridPos.y):
						curent_obje2.position = newPoint
					else:
						flipPieceH(false)
				elif p2grid.x != 5:
					var newPoint = Vector2(curent_obje1.position.x+height_width,curent_obje1.position.y)
					var gridPos = gemEngine.pixel_to_grid(newPoint.x,newPoint.y)
					if isCellEmpty(gridPos.x,gridPos.y):
						curent_obje2.position = newPoint
					else:
						newPoint = Vector2(curent_obje1.position.x,curent_obje1.position.y)
						gridPos = gemEngine.pixel_to_grid(newPoint.x,newPoint.y)
						if isCellEmpty(gridPos.x-1,gridPos.y):
							curent_obje2.position = Vector2(newPoint.x,newPoint.y)
							curent_obje1.position = Vector2(newPoint.x - height_width,newPoint.y)
						else:
							flipPieceH(false)
				else:
					var newPoint = Vector2(curent_obje1.position.x,curent_obje1.position.y)
					var gridPos = gemEngine.pixel_to_grid(newPoint.x,newPoint.y)
					if isCellEmpty(gridPos.x-1,gridPos.y):
						curent_obje2.position = Vector2(newPoint.x,newPoint.y)
						curent_obje1.position = Vector2(newPoint.x - height_width,newPoint.y)
					else:
						flipPieceH(false)
			else:
				if p2grid.x != 0 :
					var newPoint = Vector2(curent_obje1.position.x-height_width,curent_obje1.position.y)
					var gridPos = gemEngine.pixel_to_grid(newPoint.x,newPoint.y)
					if isCellEmpty(gridPos.x,gridPos.y):
						curent_obje2.position = newPoint
					else:
						newPoint = Vector2(curent_obje1.position.x,curent_obje1.position.y)
						gridPos = gemEngine.pixel_to_grid(newPoint.x,newPoint.y)
						if isCellEmpty(gridPos.x+1,gridPos.y):
							curent_obje2.position = Vector2(newPoint.x,newPoint.y)
							curent_obje1.position = Vector2(newPoint.x + height_width,newPoint.y)
						else:
							flipPieceH(false)
				else:
					var newPoint = Vector2(curent_obje1.position.x,curent_obje1.position.y)
					var gridPos = gemEngine.pixel_to_grid(newPoint.x,newPoint.y)
					if isCellEmpty(gridPos.x+1,gridPos.y):
						curent_obje2.position = Vector2(newPoint.x,newPoint.y)
						curent_obje1.position = Vector2(newPoint.x + height_width,newPoint.y)
					else:
						flipPieceH(false)
		else:
			if isClockWise:
				if p1grid.x != 0 :
					var newPoint = Vector2(curent_obje1.position.x-height_width,curent_obje1.position.y)
					var gridPos = gemEngine.pixel_to_grid(newPoint.x,newPoint.y)
					if isCellEmpty(gridPos.x,gridPos.y):
						curent_obje2.position = newPoint
					else:
						newPoint = Vector2(curent_obje1.position.x,curent_obje1.position.y)
						gridPos = gemEngine.pixel_to_grid(newPoint.x,newPoint.y)
						if isCellEmpty(gridPos.x+1,gridPos.y):
							curent_obje2.position = Vector2(newPoint.x,newPoint.y)
							curent_obje1.position = Vector2(newPoint.x + height_width,newPoint.y)
						else:
							flipPieceH(false)
				else:
					var newPoint = Vector2(curent_obje1.position.x,curent_obje1.position.y)
					var gridPos = gemEngine.pixel_to_grid(newPoint.x,newPoint.y)
					if isCellEmpty(gridPos.x+1,gridPos.y):
						curent_obje2.position = Vector2(newPoint.x,newPoint.y)
						curent_obje1.position = Vector2(newPoint.x + height_width,newPoint.y)
					else:
						flipPieceH(false)
			else:
				if p2grid.x == 0:
					var newPoint = Vector2(curent_obje1.position.x+height_width,curent_obje1.position.y)
					var gridPos = gemEngine.pixel_to_grid(newPoint.x,newPoint.y)
					if isCellEmpty(gridPos.x,gridPos.y):
						curent_obje2.position = newPoint
					else:
						flipPieceH(false)
				elif p2grid.x != 5 :
					var newPoint = Vector2(curent_obje1.position.x+height_width,curent_obje1.position.y)
					var gridPos = gemEngine.pixel_to_grid(newPoint.x,newPoint.y)
					if isCellEmpty(gridPos.x,gridPos.y):
						curent_obje2.position = newPoint
					else:
						newPoint = Vector2(curent_obje1.position.x,curent_obje1.position.y)
						gridPos = gemEngine.pixel_to_grid(newPoint.x,newPoint.y)
						if isCellEmpty(gridPos.x-1,gridPos.y):
							curent_obje2.position = Vector2(newPoint.x,newPoint.y)
							curent_obje1.position = Vector2(newPoint.x - height_width,newPoint.y)
						else:
							flipPieceH(false)
				else:
					var newPoint = Vector2(curent_obje1.position.x,curent_obje1.position.y)
					var gridPos = gemEngine.pixel_to_grid(newPoint.x,newPoint.y)
					if isCellEmpty(gridPos.x-1,gridPos.y):
						curent_obje2.position = Vector2(newPoint.x,newPoint.y)
						curent_obje1.position = Vector2(newPoint.x - height_width,newPoint.y)
					else:
						flipPieceH(false)
		
	elif is_check_pairInSameHLine():
		if !check1PieceXSide:
			if isClockWise:
				if p2grid.y < 13:
					var newPoint = Vector2(curent_obje1.position.x,curent_obje1.position.y-height_width)
					var gridPos = gemEngine.pixel_to_grid(newPoint.x,newPoint.y)
					if isCellEmpty(gridPos.x,gridPos.y):
						curent_obje2.position = newPoint
					else:
						flipPieceH(true)
			else:
				if p2grid.y != 0:
					var newPoint = Vector2(curent_obje1.position.x,curent_obje1.position.y+height_width)
					var gridPos = gemEngine.pixel_to_grid(newPoint.x,newPoint.y)
					if isCellEmpty(gridPos.x,gridPos.y):
						curent_obje2.position = newPoint
					else:
						flipPieceH(true)
		else:
			if isClockWise:
				if p2grid.y < 13:
					var newPoint = Vector2(curent_obje1.position.x,curent_obje1.position.y+height_width)
					var gridPos = gemEngine.pixel_to_grid(newPoint.x,newPoint.y)
					if isCellEmpty(gridPos.x,gridPos.y):
						curent_obje2.position = newPoint
					else:
						flipPieceH(true)
			else:
				if p2grid.y != 0:
					var newPoint = Vector2(curent_obje1.position.x,curent_obje1.position.y-height_width)
					var gridPos = gemEngine.pixel_to_grid(newPoint.x,newPoint.y)
					if isCellEmpty(gridPos.x,gridPos.y):
						curent_obje2.position = newPoint
					else:
						flipPieceH(true)
	playMovedSound()
	isRotateIn = false
	setPlaceHolderPosition()


func onTouchRotation(_location):
	if curent_obje1 != null:
		if curent_obje1.global_position.distance_to(_location) < 40:
				rotate_piece_(true)
				return true
	if curent_obje2 != null:
		if curent_obje2.global_position.distance_to(_location) < 40:
			rotate_piece_(true)
			return true

	return false




# Check both gem is in same verticel line
func is_check_pairInSameVLine():
	var piece1Pos = gemEngine.pixel_to_grid(curent_obje1.position.x,curent_obje1.position.y)
	var piece2Pos = gemEngine.pixel_to_grid(curent_obje2.position.x,curent_obje2.position.y)
	if piece1Pos.x == piece2Pos.x:
		return true
	return false

#Check both gem is in same horizonal line
func is_check_pairInSameHLine():
	var piece1Pos = gemEngine.pixel_to_grid(curent_obje1.position.x,curent_obje1.position.y)
	var piece2Pos = gemEngine.pixel_to_grid(curent_obje2.position.x,curent_obje2.position.y)
	if piece1Pos.y == piece2Pos.y:
		return true
	return false


#use to flip gem pair : flag == true for flipping horizintally 
func flipPieceH(flag):
	if flag:
		var obje2Pos = curent_obje2.position.x
		curent_obje2.position.x = curent_obje1.position.x
		curent_obje1.position.x = obje2Pos
	else:
		var obje2Pos = curent_obje2.position.y
		curent_obje2.position.y = curent_obje1.position.y
		curent_obje1.position.y = obje2Pos

#return piece grid position
func get_piece_grid(objePiece):
	return gemEngine.pixel_to_grid(objePiece.position.x,objePiece.position.y)

#use to check which piece is above or at left side.
func check_first_piece_side(isCheckV):
	var piece1Pos = gemEngine.pixel_to_grid(curent_obje1.position.x,curent_obje1.position.y)
	var piece2Pos = gemEngine.pixel_to_grid(curent_obje2.position.x,curent_obje2.position.y)
	if isCheckV:
		#check which is above and bottom
		if piece1Pos.y < piece2Pos.y:
			return true
		else:
			return false
	else:
		#check which piece is left side
		if piece1Pos.x < piece2Pos.x:
			return true
		else:
			return false

#check cell is empty at given position
func isCellEmpty(row,column):
	if row > 5 or column > 12:
		return false
	if all_pieces[row][column] == null:
		return true
	else:
		return false

#call this fuction after each pair is dropped , called only once 
func get_piece_FixPosition():
	dropCount = 0
	gemEngine.fire_findMatrix(diamonGemIn)
	newPieceLoaded = false
	diamonGemIn = null


#singal from GemEngine : return position of gem remove from scene
func _on_piece_removeAt(_position):
	if playerType == GLOBAL.PlayerMode.PLAYER:
		#$BoomSound.play()
		if isCanPlaySound:
			var playSong = SoundMrg.instance()
			add_child(playSong)
			playSong.loadSoundWithID()
	var objeBoom = BoomAnime.instance()
	add_child(objeBoom)
	objeBoom.position = _position

#singal from GemEngine : drop animation trigger for object
func dropAnimation_piece(obje,targetPos):
	effectTween.interpolate_property(obje,"position",obje.position,targetPos,0.2,Tween.TRANS_QUART,Tween.EASE_IN)
	effectTween.start()

# tween object animation complete callback
func _on_effect_tween_completed(object, key):
	pass # replace with function body

#singal from GemEngine : used to wait for animation finished and call rearrange
func _call_time_delay():
	var t = Timer.new()
	t.set_wait_time(0.3)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	t.connect("timeout",self,"_on_rearrange_checked") 
	yield(t, "timeout")

#timer callback 
func _on_rearrange_checked():
	if gemEngine.chainReactionCount > 1 :
		showChainLable(gemEngine.chainReactionCount)
	if extraGem != null:
		if not extraLock:
			extraLock = true
			_fixed_extraGem()
	else:
		gemEngine.find_matrix()
	

#singal from GemEngine : to show chain reaction counts
func showChainLable(count):
	if lblNode != null:
		lblNode.removeFromParent()
		lblNode = null
		
	var objCount = LableChain.instance()
	lblNode = objCount
	objCount.z_index = 3
	objCount.get_node("Label").text = str(count) + " Chains.."
	add_child(objCount)
	var pos = gemEngine.grid_to_pixel(2,2)
	objCount.position = pos
	objCount.startAnime(pos)
	objCount.connect("lbl_anime_done",self, "_lbl_anime_complete")
	
	_update_score(scoreManager.inpu_chain(1))
	

#chain reaction animation complete callback
func _lbl_anime_complete():
	lblNode = null

#singal from GemEngine : update score in UI
func _update_score(tmpscore):
	score += tmpscore
	var lenth = str(score).length()
	var zero = 8-lenth
	var strNew = ""
	for i in zero:
		strNew += "0"
	strNew += str(score)
	$lblScore.text = strNew

#Signal from gemEngine : Update power gem in UI
func _get_powerGemScore(score,pos):
	emit_signal("powerGemScore",score,pos)
	pass

#singal from GemEngine : call when all animation is finished in gemEngine and trigger for new pair to drop in scene

func _dropNewPair():
	if not ignoreSignal:
		return
	if timerPair == null:
		timerPair = Timer.new()
		add_child(timerPair)
		timerPair.connect("timeout",self,"_dropNewPair_Timer_Out")
	
	timerPair.stop()
	timerPair.set_wait_time(0.8)
	timerPair.set_one_shot(true)
	timerPair.start()


# drop animation timer callback
func _dropNewPair_Timer_Out():
	timerPair.stop()


## call_AI_func() will only use for AI player in second player script
func call_AI_func():
	pass

#Check for 4th column is empty for new gem 
func checkColumnDrop():
	if all_pieces[3][12] != null:
		_fire_GameOver()
		return false
	return true


#if 4th column is not empty then trigger game over signal
func _fire_GameOver():
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
	emit_signal("GameOver")


# This called when other player's game is over
func showYouWin():
	ignoreSignal = false
	gmState = GLOBAL.GameState.NONE
	


#Counter Gem Manage
var arrCounterGemHolder = []
#Flag that handle drop of counter gems
var proccessCGem = false
var isCGemToFall = false

#to send counter in network window


#to crate counter gem in scene after pair is drop 
func _makeCounterGem():
	
	if counterGemHolder <= 0:
		_dropNewPair()
		$lblcounterGem.text = ""
		return

	var arr_cGemNet = []
	var totalCounter = counterGemHolder
	counterGemHolder = 0
	var totalFullRow = totalCounter/6
	var emptyCol = []
	randomize()
	
	var targetPos = []
	var originPos = []
	
	for i in width:
		var y = 1
		var yPos = 13
		var flag = false
		for y in height:
			if all_pieces[i][y] == null:
				if not flag: 
					yPos = y
					flag = true
			else:
				flag = false
		
		if all_pieces[i][height-1] == null:
			emptyCol.append(i)
		for j in range(0,totalFullRow):
			var cNode = counterPieceHolder[i][j%4].instance()
			add_child(cNode)
			cNode.position = gemEngine.grid_to_pixel(i,height-1+y)
			cNode.targetPos = gemEngine.grid_to_pixel(i,yPos)
			arrCounterGemHolder.append(cNode)
			var netcGem = {"cgem":[i,j%4],"spos":[i,height-1+y],"tpos":[i,yPos]}
			arr_cGemNet.append(netcGem)
			y += 1
			yPos += 1
		targetPos.append(yPos)
		originPos.append(y)
	
	
	if emptyCol.size() > 2:
		emptyCol.erase(3)
	
	for no in range(0,totalCounter%6):
		if emptyCol.empty():
			break
		var col = emptyCol[randi() % emptyCol.size()]
		emptyCol.erase(col)
		var cNode = counterPieceHolder[col][totalFullRow%4].instance()
		add_child(cNode)
		var y = originPos[col]
		var yPos = targetPos[col]
		cNode.position = gemEngine.grid_to_pixel(col,height-1+y)
		cNode.targetPos = gemEngine.grid_to_pixel(col,yPos)
		targetPos[col] = yPos + 1
		originPos[col] = y+1
		arrCounterGemHolder.append(cNode)
		
		var netcGem = {"cgem":[col,totalFullRow%4],"spos":[col,height-1+y],"tpos":[col,yPos]}
		arr_cGemNet.append(netcGem)
	
	proccessCGem = true
	
	#is playing in multiplayer
	if GLOBAL.isNetworked:
		var home = self.get_parent().get_parent()
		if home != null && home.name == "Home":
			home.send_counter_gemToRemoteWindow(arr_cGemNet)
		pass
	

#Show couter gem in scene from top to bottom animation
func _dropCounterGem():
	var isTouched = false
	var isRowFlag = false
	for item in arrCounterGemHolder:
		if not item.isDroped:
			if item.position.y+20 < item.targetPos.y:
				item.position.y += (FREE_DROP_DELTA * DROP_DEFAULT_SPEED)
				isRowFlag = true
			else:
				item.position.y = item.targetPos.y
				item.isDroped = true
				isTouched = true
	
	if isTouched && not isRowFlag:
		proccessCGem = false
		var arrGemRemove = []
		for item in arrCounterGemHolder:
			var pos = gemEngine.pixel_to_grid(item.position.x,item.position.y)
			if pos.y < height:
				all_pieces[pos.x][pos.y] = item
				item.myPos = Vector2(pos.x,pos.y)
			else:
				arrGemRemove.append(item)
		
		for item in arrGemRemove:
			item.removeFromParent()
		arrGemRemove = []
		arrCounterGemHolder = []
		_dropNewPair()
		$lblcounterGem.text = ""

#Get Crashed Gem Counter from Engine
#singal from GemEngine :
func _gem_crashed_signal(counts):
	var gemToSend = counts 
	isNetcGemSend = true
	pre_sender = counts
	if counterGemHolder != 0:
		isNetcGemSend = false
		pre_sender = 0
		var halfGems = int(gemToSend/2)
		var extra = gemToSend%2
		
		if halfGems >= counterGemHolder:
			gemToSend = (halfGems - counterGemHolder) + extra
			counterGemHolder = 0
			isCGemToFall = false
		else:
			gemToSend = 0
			counterGemHolder = counterGemHolder - halfGems
			$lblcounterGem.text = str(counterGemHolder)
	
	
	if gemToSend != 0:
		emit_signal("SendCounterGem",gemToSend)
	pass

#Called when other player send counter gem and you received that
#singal from other player :
func _received_CounterGem(count):
	isCGemToFall = true
	counterGemHolder += count
	$lblcounterGem.text = str(counterGemHolder)
	pass


#singla from counter gem : wait for gem animation to normal
func _counter_to_normal(obje, time = 0.7):
	var t = Timer.new()
	t.set_wait_time(time)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	gemEngine.gem_Converted(obje)
	t.queue_free()


#singla from counter gem : add powerGem 
func _create_power_gem_At(_position,_size,_color):
	var gridPos = gemEngine.pixel_to_grid(_position.x,_position.y) 
	var obj = all_pieces[gridPos.x][gridPos.y]
	if obj != null :
		var gem = preload("res://scenes/pieces/PowerGem/PowerGemBase.tscn").instance()
		gem.z_index = 2
		obj.add_child(gem)
		gem.position = Vector2(0,0)
		gem.changeTexture(_color,_size,offset)
	pass


##
## Network Player Implementation
func fire_new_pair():
	if is_network_master() && not newPieceLoaded :
		newPieceLoaded = true
		spaw_pair_from_top()
		get_node(".").get_parent().send_cmd_spawnPair()
#		if not newPieceLoaded :
#			newPieceLoaded = true
#			spaw_pair_from_top()
#			get_node(".").get_parent().send_cmd_spawnPair()
	pass


slave func _rotate_remote(isclockwise):
	if curent_obje2 != null and curent_obje1 != null:
		rotate_piece_(isclockwise)

slave func _move_right_left_remote(isLeft):
	move_piece_left_right(isLeft)

slave func _drop_piece_remote(flag):
	isDropedIn = flag

#Send Counter Gems
func send_counterGemToClient(counts):
#	if (is_network_master()):
#		rpc_unreliable("counterGem_byClient_remote",counts)
	pass
	
slave func counterGem_byClient_remote(counts):
#	if (is_network_master()):
#		_received_CounterGem(counts)
#	else:
#		emit_signal("CounterFromRemote",counts)
	if GLOBAL.isHost:
		_received_CounterGem(counts)
	else:
		emit_signal("CounterFromRemote",counts)
	pass

## To send initial Data to Client
func send_initialData():
	pass
	
# Client receive pair from server
slave func send_current_pair_remote(newPair):
	pass


#Drop Countergem to Remote window 
func drop_counterGemIn_remoteWindow(array):
	
	for item in array:
		#{"cgem":[col,totalFullRow%4],"spos":[col,height-1+y],"tpos":[col,yPos]}
		var grid = item["cgem"]
		var spos = item["spos"]
		var tpos = item["tpos"]
		
		var cNode = counterPieceHolder[grid[0]][grid[1]].instance()
		add_child(cNode)
		cNode.position = gemEngine.grid_to_pixel(spos[0],spos[1])
		cNode.targetPos = gemEngine.grid_to_pixel(tpos[0],tpos[1])
		arrCounterGemHolder.append(cNode)
	isCGemToFall = true
	proccessCGem = true
	
	pass

func counterPatternGenret(index):
	counterPatternHolder = []
	
	var objePattern = preload("res://scripts/PlayerPattern/PlayerPattern.gd").PlayerPattern.new()
	counterPatternHolder = objePattern.getPatternFromIndex(index)

	counterPieceHolder = []
	for i in 6:
		counterPieceHolder.append([])
		for j in [3,2,1,0]:
			counterPieceHolder[i].append(getCounterGemNew(counterPatternHolder[j][i]))
		
func getCounterGemNew(color):
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
			print("Get null")
	return cNode