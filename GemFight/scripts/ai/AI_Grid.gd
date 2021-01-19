extends Node2D

# Grid Variables
export (int) var width;
export (int) var height;
export (int) var x_start;
export (int) var y_start;
export (int) var offset;

onready var effectTween = get_node("effect")

var all_pieces = [];

# State : Running, Gameover,NotRunning
var gmState

# Mode : Easy,Normal,Hard
var gmMode

# Drop Current Gem Quickly
var isDropedIn = false

#Check Drop Pair isn't breaked
var isCurentPairBreak = false

#Pair Object holder
var curent_obje1
var curent_obje2

# Drop Delta for faster Fall
var FREE_DROP_DELTA = 0.3

# Default Pair Drop speed
var DROP_DEFAULT_SPEED = 100

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

var PlaceHolder = preload("res://scenes/pieces/Dot_Piece.tscn")
var ObjeGemEngine = preload("res://scripts/Engine/GemEngine.gd")
var gemEngine
var pairManager

# To manage AI operation once per pair
var isAICalled = false

var AI_ANIM_TIME = 0.09

func _ready():
	gmState = GLOBAL.GameState.RUNNING
	all_pieces = make_2d_array()
	gemEngine = ObjeGemEngine.GemEngine.new(all_pieces,height,width,x_start,y_start,offset)
	gemEngine.connect("boomAnime",self,"_on_piece_removeAt")
	gemEngine.connect("dropAnime",self,"dropAnimation_piece")
	gemEngine.connect("timeAnime",self,"_call_time_delay")
	gemEngine.connect("showChain",self,"showChainLable")
	
	
	pairManager = ObjeGemEngine.PairEngine.new() #GLOBAL.PairManager#
	spawn_pieces()
	get_columnNCounts()
	pass

func spawn_pieces():
	for i in width:
		for j in height:
			var piece = PlaceHolder.instance()
			add_child(piece)
			piece.position = gemEngine.grid_to_pixel(i,j)

# create grid empty array :
func make_2d_array():
	var array = [];
	for i in width:
		array.append([]);
		for j in height:
			array[i].append(null);
	return array;
	

func _physics_process(delta):
	if gmState == GLOBAL.GameState.RUNNING:
		var factDelta = delta
		if isDropedIn:
			factDelta += 0.5
		drop_pair_to_End(factDelta)
	pass

func _input(event):
	if gmState == GLOBAL.GameState.RUNNING:
		if event.is_action_pressed("ui_accept"):
			if not newPieceLoaded:
				newPieceLoaded = true
				spaw_pair_from_top()
		elif event.is_action_pressed("ui_touch"):
			if not newPieceLoaded:
				var mPos = get_viewport().get_mouse_position()*2
				var gCord = gemEngine.pixel_to_grid(mPos.x,mPos.y)
				addPieceAtPos(gCord)
		elif event.is_action_released("spawn_pair"):
			if not newPieceLoaded:
				newPieceLoaded = true
#				var gemtype = "n"
#				if $Control/lbl1.text == "r":
#					gemtype = "dia"
				var obje1 = get_piesce($Control/lbl1.text,"n") #preload("res://scenes/pieces/Green_Piece.tscn").instance()#LOBAL.DiamondGemLoader.instance() #CrashGem.instance() #
				var obje2 = get_piesce($Control/lbl2.text,"c") #preload("res://scenes/pieces/Green_Piece.tscn").instance()
				#diamonGemIn = obje1
				isAICalled = false
				curent_obje1 = obje1
				curent_obje2 = obje2
				add_child(curent_obje1)
				add_child(curent_obje2)
				curent_obje1.position = gemEngine.grid_to_pixel(3,12)
				curent_obje2.position = gemEngine.grid_to_pixel(3,13)
				isCurentPairBreak = false
				isDropedIn = false
				
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
		elif event.is_action_released("drop"):
			isDropedIn = false


func addPieceAtPos(posGird):
	
	if posGird.x >= 0 and posGird.x < width and posGird.y >= 0 and posGird.y < height:
		var cNode = get_piesce(GLOBAL.selectColor,GLOBAL.isCrashOn)
#		if not GLOBAL.isCrashOn == "n":
#			if GLOBAL.selectColor == "r":
#				cNode = GLOBAL.possible_pieces[0].instance()
#			elif GLOBAL.selectColor == "g":
#				cNode = GLOBAL.possible_pieces[1].instance()
#			elif GLOBAL.selectColor == "y":
#				cNode = GLOBAL.possible_pieces[3].instance()
#			elif GLOBAL.selectColor == "b":
#				cNode = GLOBAL.possible_pieces[2].instance()
#		else:
#			if GLOBAL.selectColor == "r":
#				cNode = GLOBAL.possible_pieces[4].instance()
#			elif GLOBAL.selectColor == "g":
#				cNode = GLOBAL.possible_pieces[5].instance()
#			elif GLOBAL.selectColor == "y":
#				cNode = GLOBAL.possible_pieces[7].instance()
#			elif GLOBAL.selectColor == "b":
#				cNode = GLOBAL.possible_pieces[6].instance()
		if all_pieces[posGird.x][posGird.y] != null:
			all_pieces[posGird.x][posGird.y].removeFromParent()
		cNode.position = gemEngine.grid_to_pixel(posGird.x,posGird.y)
		cNode.myPos = Vector2(posGird.x,posGird.y)
		all_pieces[posGird.x][posGird.y] = cNode
		add_child(cNode)
		pass

func get_piesce(color,isCrash):
	var cNode
	if isCrash == "n":
		if color == "r":
			cNode = GLOBAL.possible_pieces[0].instance()
		elif color == "g":
			cNode = GLOBAL.possible_pieces[1].instance()
		elif color == "y":
			cNode = GLOBAL.possible_pieces[3].instance()
		elif color == "b":
			cNode = GLOBAL.possible_pieces[2].instance()
	else:
		if color == "r":
			#cNode = GLOBAL.possible_pieces[4].instance()
			cNode = GLOBAL.DiamondGemLoader.instance()
		elif color == "g":
			cNode = GLOBAL.possible_pieces[5].instance()
		elif color == "y":
			cNode = GLOBAL.possible_pieces[7].instance()
		elif color == "b":
			cNode = GLOBAL.possible_pieces[6].instance()
	return cNode

#Default drop animation with 
func drop_pair_to_End(factor):
	if not isCurentPairBreak:
		#if not isRotateIn:
			if not isAICalled && curent_obje1 != null:
				if curent_obje2.position.y >= gemEngine.grid_to_pixel(0,13).y + 40:
					call_AI()
			if curent_obje1 != null:
				if not manage_piece_position(curent_obje1,factor):
					curent_obje1 = null
					isCurentPairBreak = true
					dropCount = dropCount + 1

			if curent_obje2 != null:
				if not manage_piece_position(curent_obje2,factor):
					curent_obje2 = null
					isCurentPairBreak = true
					dropCount = dropCount + 1

	else :
		if curent_obje1 != null:
			if not manage_piece_position(curent_obje1,FREE_DROP_DELTA):
				curent_obje1 = null
				dropCount = dropCount + 1

		if curent_obje2 != null:
			if not manage_piece_position(curent_obje2,FREE_DROP_DELTA):
				curent_obje2 = null
				dropCount = dropCount + 1
	if dropCount == 2:
		get_piece_FixPosition()

#Drop pic at bottom if find empty space
func manage_piece_position(myGem,factor):
	var gridPos = gemEngine.pixel_to_grid(myGem.position.x,myGem.position.y)
	var targetPosY = gemEngine.grid_to_pixel(0,0).y
	for i in height:
		if all_pieces[gridPos.x][i] != null:
			targetPosY = gemEngine.grid_to_pixel(gridPos.x,i+1).y
	if myGem.position.y < targetPosY:
		myGem.position.y = myGem.position.y + (factor * DROP_DEFAULT_SPEED)
	else:
		var gridPos2 = gemEngine.pixel_to_grid(myGem.position.x,targetPosY)
		if gridPos2.y >= height && myGem.position.x == 3:
			gmState = GLOBAL.GameState.GAMEOVER
			print("OVER")
			return false
		if gridPos2.y >= height:
			return false
		all_pieces[gridPos2.x][gridPos2.y] = myGem
		return false
		
	return true

# add New pair in scene for drop
func spaw_pair_from_top():
	diamonGemIn = null
	var newPair = pairManager.provide_new_pair(false)
	curent_obje1 = newPair[0].instance()
	curent_obje2 = newPair[1].instance()
#	curent_obje2 = preload("res://scenes/pieces/Blue_Piece.tscn").instance()
#	curent_obje1 = preload("res://scenes/pieces/Blue_Piece.tscn").instance()
#	curent_obje2 = preload("res://scenes/pieces/crash_gem/Red_CrashPiece.tscn").instance()

	add_child(curent_obje1)
	add_child(curent_obje2)
	curent_obje1.position = gemEngine.grid_to_pixel(3,12)
	curent_obje2.position = gemEngine.grid_to_pixel(3,13)
	isCurentPairBreak = false
	isDropedIn = false
	isAICalled = false
	if curent_obje1.gemType == GLOBAL.GemTypes.DIAMOND:
		diamonGemIn = curent_obje1
	elif curent_obje2.gemType == GLOBAL.GemTypes.DIAMOND:
		diamonGemIn = curent_obje2

#Moving Opearation
func move_piece_left_right(isLeft):
	#check first obje1 is left/right side
	var height_width = curent_obje2.get_node("Sprite").texture.get_size().y/2
	if is_check_pairInSameVLine():
		var gridColumn = get_piece_grid(curent_obje1)
		if isLeft:
			if gridColumn.x != 0:
				var newY = gemEngine.grid_to_pixel(gridColumn.x-1,gridColumn.y).x
				if isCellEmpty(gridColumn.x-1,gridColumn.y):
					curent_obje1.position.x = newY
					curent_obje2.position.x = newY
		else:
			if gridColumn.x != width-1:
				var newY = gemEngine.grid_to_pixel(gridColumn.x+1,gridColumn.y).x
				if isCellEmpty(gridColumn.x+1,gridColumn.y):
					curent_obje1.position.x = newY
					curent_obje2.position.x = newY
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
			else:
				var gridColumn = get_piece_grid(curent_obje2)
				if gridColumn.x != 5:
					var newY = gemEngine.grid_to_pixel(gridColumn.x+1,gridColumn.y).x
					if isCellEmpty(gridColumn.x+1,gridColumn.y):
						curent_obje1.position.x = newY - height_width
						curent_obje2.position.x = newY
		else:
			if isLeft:
				var gridColumn = get_piece_grid(curent_obje2)
				if gridColumn.x != 0:
					var newY = gemEngine.grid_to_pixel(gridColumn.x-1,gridColumn.y).x
					if isCellEmpty(gridColumn.x-1,gridColumn.y):
						curent_obje1.position.x = newY + height_width
						curent_obje2.position.x = newY
			else:
				var gridColumn = get_piece_grid(curent_obje1)
				if gridColumn.x != 5:
					var newY = gemEngine.grid_to_pixel(gridColumn.x+1,gridColumn.y).x
					if isCellEmpty(gridColumn.x+1,gridColumn.y):
						curent_obje1.position.x = newY 
						curent_obje2.position.x = newY - height_width

#Rotate Pair
func rotate_piece_(isClockWise):
	
	var p1grid = get_piece_grid(curent_obje1)
	var p2grid = get_piece_grid(curent_obje2)
	var height_width = curent_obje2.get_node("Sprite").texture.get_size().y/2
	var check1PieceXSide = check_first_piece_side(false)
	var check1PieceYSide = check_first_piece_side(true)
	
	if is_check_pairInSameVLine():
		if check1PieceYSide:
			if isClockWise:
				if p2grid.x != 5 :
					var newPoint = Vector2(curent_obje1.position.x+height_width,curent_obje1.position.y)
					var gridPos = gemEngine.pixel_to_grid(newPoint.x,newPoint.y)
					if isCellEmpty(gridPos.x,gridPos.y):
						curent_obje2.position = newPoint
					else:
						flipPieceH(false)
			else:
				if p2grid.x != 0 :
					var newPoint = Vector2(curent_obje1.position.x-height_width,curent_obje1.position.y)
					var gridPos = gemEngine.pixel_to_grid(newPoint.x,newPoint.y)
					if isCellEmpty(gridPos.x,gridPos.y):
						curent_obje2.position = newPoint
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
						flipPieceH(false)
			else:
				if p2grid.x != 5 :
					var newPoint = Vector2(curent_obje1.position.x+height_width,curent_obje1.position.y)
					var gridPos = gemEngine.pixel_to_grid(newPoint.x,newPoint.y)
					if isCellEmpty(gridPos.x,gridPos.y):
						curent_obje2.position = newPoint
					else:
						flipPieceH(false)
						
	elif is_check_pairInSameHLine():
		if !check1PieceXSide:
			if isClockWise:
				if p2grid.y != 12:
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
				if p2grid.y != 12:
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
	
	isRotateIn = false
	
#func rotate_piece_(isClockWise):
#
#	var p1grid = get_piece_grid(curent_obje1)
#	var p2grid = get_piece_grid(curent_obje2)
#	var height_width = curent_obje2.get_node("Sprite").texture.get_size().y/2
#	var check1PieceXSide = check_first_piece_side(false)
#	var check1PieceYSide = check_first_piece_side(true)
#
#	if is_check_pairInSameVLine():
#		if !check1PieceYSide:
#			if isClockWise:
#				if p1grid.x != 5 :
#					var newPoint = Vector2(curent_obje2.position.x+height_width,curent_obje2.position.y)
#					var gridPos = gemEngine.pixel_to_grid(newPoint.x,newPoint.y)
#					if isCellEmpty(gridPos.x,gridPos.y):
#						curent_obje1.position = newPoint
#					else:
#						flipPieceH(false)
#			else:
#				if p1grid.x != 0 :
#					var newPoint = Vector2(curent_obje2.position.x-height_width,curent_obje2.position.y)
#					var gridPos = gemEngine.pixel_to_grid(newPoint.x,newPoint.y)
#					if isCellEmpty(gridPos.x,gridPos.y):
#						curent_obje1.position = newPoint
#					else:
#						flipPieceH(false)
#		else:
#			if isClockWise:
#				if p1grid.x != 0 :
#					var newPoint = Vector2(curent_obje2.position.x-height_width,curent_obje2.position.y)
#					var gridPos = gemEngine.pixel_to_grid(newPoint.x,newPoint.y)
#					if isCellEmpty(gridPos.x,gridPos.y):
#						curent_obje1.position = newPoint
#					else:
#						flipPieceH(false)
#			else:
#				if p1grid.x != 5 :
#					var newPoint = Vector2(curent_obje2.position.x+height_width,curent_obje2.position.y)
#					var gridPos = gemEngine.pixel_to_grid(newPoint.x,newPoint.y)
#					if isCellEmpty(gridPos.x,gridPos.y):
#						curent_obje1.position = newPoint
#					else:
#						flipPieceH(false)
#
#	elif is_check_pairInSameHLine():
#		if check1PieceXSide:
#			if isClockWise:
#				if p1grid.y != 12:
#					var newPoint = Vector2(curent_obje2.position.x,curent_obje2.position.y-height_width)
#					var gridPos = gemEngine.pixel_to_grid(newPoint.x,newPoint.y)
#					if isCellEmpty(gridPos.x,gridPos.y):
#						curent_obje1.position = newPoint
#					else:
#						flipPieceH(true)
#			else:
#				if p1grid.y != 0:
#					var newPoint = Vector2(curent_obje2.position.x,curent_obje2.position.y+height_width)
#					var gridPos = gemEngine.pixel_to_grid(newPoint.x,newPoint.y)
#					if isCellEmpty(gridPos.x,gridPos.y):
#						curent_obje1.position = newPoint
#					else:
#						flipPieceH(true)
#		else:
#			if isClockWise:
#				if p1grid.y != 12:
#					var newPoint = Vector2(curent_obje2.position.x,curent_obje2.position.y+height_width)
#					var gridPos = gemEngine.pixel_to_grid(newPoint.x,newPoint.y)
#					if isCellEmpty(gridPos.x,gridPos.y):
#						curent_obje1.position = newPoint
#					else:
#						flipPieceH(true)
#			else:
#				if p1grid.y != 0:
#					var newPoint = Vector2(curent_obje2.position.x,curent_obje2.position.y-height_width)
#					var gridPos = gemEngine.pixel_to_grid(newPoint.x,newPoint.y)
#					if isCellEmpty(gridPos.x,gridPos.y):
#						curent_obje1.position = newPoint
#					else:
#						flipPieceH(true)
#
#	isRotateIn = false


func is_check_pairInSameVLine():
	var piece1Pos = gemEngine.pixel_to_grid(curent_obje1.position.x,curent_obje1.position.y)
	var piece2Pos = gemEngine.pixel_to_grid(curent_obje2.position.x,curent_obje2.position.y)
	if piece1Pos.x == piece2Pos.x:
		return true
	return false
	
func is_check_pairInSameHLine():
	var piece1Pos = gemEngine.pixel_to_grid(curent_obje1.position.x,curent_obje1.position.y)
	var piece2Pos = gemEngine.pixel_to_grid(curent_obje2.position.x,curent_obje2.position.y)
	if piece1Pos.y == piece2Pos.y:
		return true
	return false

func flipPieceH(flag):
	if flag:
		var obje2Pos = curent_obje2.position.x
		curent_obje2.position.x = curent_obje1.position.x
		curent_obje1.position.x = obje2Pos
	else:
		var obje2Pos = curent_obje2.position.y
		curent_obje2.position.y = curent_obje1.position.y
		curent_obje1.position.y = obje2Pos

func get_piece_grid(objePiece):
	return gemEngine.pixel_to_grid(objePiece.position.x,objePiece.position.y)

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

func isCellEmpty(row,column):
	if row > 5 or column > 12:
		return false
	if all_pieces[row][column] == null:
		return true
	else:
		return false

func _on_piece_removeAt(_position):
	var objeBoom = BoomAnime.instance()
	add_child(objeBoom)
	objeBoom.position = _position


func dropAnimation_piece(obje,targetPos):
	effectTween.interpolate_property(obje,"position",obje.position,targetPos,0.2,Tween.TRANS_QUART,Tween.EASE_IN)
	effectTween.start()


#func _on_effect_tween_completed(object, key):
#	pass # replace with function body

func _call_time_delay():
	var t = Timer.new()
	t.set_wait_time(0.3)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	t.connect("timeout",self,"_on_rearrange_checked") 
	yield(t, "timeout")


func _on_rearrange_checked():
	if gemEngine.chainReactionCount > 1 :
		showChainLable(gemEngine.chainReactionCount)
	gemEngine.find_matrix()
	

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

func _lbl_anime_complete():
	lblNode = null


####
#### Call this function after pair touched to ground
#### : get_piece_FixPosition():
func get_piece_FixPosition():
	dropCount = 0
	gemEngine.fire_findMatrix(diamonGemIn)
	newPieceLoaded = false
	diamonGemIn = null
	get_columnNCounts()


####
#### Call this function after pair entered in Scene
#### : call_AI()():

var cols_counts = []
var arr_cols_counts = []
var cols_Array = [0,5,1,2,4,3]
var finalArray = []
func get_columnNCounts():
	arr_cols_counts = []
	for col in cols_Array:
		var gemCount = 0
		for row in height:
			if all_pieces[col][row] != null:
				gemCount += 1
		arr_cols_counts.append([col,gemCount])
	
	cols_counts = []
	for x in width:
		var gemCount = 0
		for y in height:
			if all_pieces[x][y] != null:
				gemCount += 1
			else:
				break
		cols_counts.append(gemCount)
	
	pass

func get_valid_columns():
	finalArray = []
	for i in [0,1,2,3,4,5]:
		var brkLoop = false
		var c = 0
		for j in height:
			if all_pieces[i][j] != null:
				if c < j:
					c = j
				c += 1
		if c >= 12:
			if i < 3:
				finalArray = []
			elif i > 3:
					brkLoop = true
					break
		else:
			finalArray.append(i)
		if brkLoop:
			break
	
	finalArray.sort()
	var tamp_colsArray = []
	for col in cols_Array:
		if finalArray.has(col):
			tamp_colsArray.append(col)
	cols_Array = tamp_colsArray
	get_columnNCounts()
#	print("finalArray :",finalArray)
#	print("Array",cols_Array)

func checkDiamondInPair():
	if curent_obje1.gemType == GLOBAL.GemTypes.DIAMOND:
		return [true,"1"]
	elif curent_obje2.gemType == GLOBAL.GemTypes.DIAMOND:
		return [true,"2"]
	else:
		return [false,"0"]
	
func call_AI():
	
	isAICalled = true	
	var rotCount = 0
	var clockWise = true
	var isRotate = false
	var count = 12
	var tmp_cols = 0
	var prev_selct_cols = 0
	
	get_valid_columns()
	
	for item in arr_cols_counts:
		if item[1] < count:
			count = item[1]
			tmp_cols = item[0]
		if count > 9:
			AI_ANIM_TIME = 0.02
			#if cols_Array.has(3):
			#	cols_Array.remove(5)
			
	prev_selct_cols = tmp_cols
	var targetCol = tmp_cols
	
	var posible1 = check_available_pos(curent_obje1)
	var posible2 = check_available_pos(curent_obje2)
	if posible1.size() != 0 && posible2.size() != 0:
		randomize()
		if curent_obje1.color == curent_obje2.color :
			#check for same in width:
			var arr_posSame = []
			var pItem 
			
			for item in posible1:
				if pItem != null:
					if pItem[1] == item[1] && item[0]-pItem[0] == 1 :
						arr_posSame.append(item[0])
				pItem = item
			if arr_posSame.size() != 0:
				targetCol = arr_posSame[0] #arr_posSame[arr_posSame.size()-1]
				isRotate = true
				clockWise = false
				rotCount = 1
				if arr_posSame.size() > 1:
					if cols_counts[arr_posSame[0]] > 8 && cols_counts[arr_posSame[1]] < 8:
						targetCol = arr_posSame[1]
				print("select ",targetCol)
			else:
				#check in each column
				var isTriangal = false
				for x in cols_Array:
					var isSideMatch = false
					var lc = 0
					var rc = 0
					for point in range(cols_counts[x],height):
						var rMatch = false
						var lMatch = false
						if x != 5 && all_pieces[x+1][point] != null && all_pieces[x+1][point].color == curent_obje1.color:
								rMatch = true
								rc += 1
								if !isTriangal:
									targetCol = x
									isTriangal = true

						if x != 0 && all_pieces[x-1][point] != null && all_pieces[x-1][point].color == curent_obje1.color:
								lMatch = true
								lc += 1
								if !isTriangal:
									targetCol = x
									isTriangal = true
								
						if not rMatch and not lMatch:
							break
						elif lc >= 2 || rc >= 2:
							targetCol = x
							isSideMatch = true
							break
					if isSideMatch:
						break						
				if !isTriangal:
					targetCol = posible1[0][0]
					
		else:
			#check same color of pair gem in grid
			var isGemSameAsPair = checkSameAsPair()
			if isGemSameAsPair != null:
				tmp_cols = isGemSameAsPair[0]
				targetCol = tmp_cols
				if isGemSameAsPair[1] == "y":
					isRotate = true
					rotCount = 2
					if tmp_cols > 3:
						clockWise = false
			else:
				# Check available pos of pair color
				var isGetSameGem_AsPair = false
				var posible1_Order = []
				var posible2_Order = []
				for col in cols_Array:
					for pCol in posible1:
						if pCol[0] == col:
							posible1_Order.append(pCol)
					for pCol in posible2:
						if pCol[0] == col:
							posible2_Order.append(pCol)
							
				for point in posible1_Order:
					var col = point[0]
					for xPoint in posible2_Order:
						# Left side match
						if xPoint[0] == col-1:
							if not checkFullSameColor([col,col-1]):
								targetCol = col
								isRotate = true
								rotCount = 1
								clockWise = false
								isGetSameGem_AsPair = true
								break
						# Right side match
						elif xPoint[0] == col + 1:
							if not checkFullSameColor([col,col+1]):
								targetCol = col
								isRotate = true
								rotCount = 1
								clockWise = true
								isGetSameGem_AsPair = true
								break
					if isGetSameGem_AsPair:
						break
				if !isGetSameGem_AsPair:
					# Check top cross gem
					var crossMatchCol1 = checkTopCrossGem(posible1)
					var crossMatchCol2 = checkTopCrossGem(posible2)
					
					if crossMatchCol1 != null:
						targetCol = crossMatchCol1
					elif crossMatchCol2 != null:
						targetCol = crossMatchCol2
						isRotate = true
						rotCount = 2
						if crossMatchCol2 > 3:
							clockWise = false
					else:
						# check both pair gem in single column. one top and secong bottom
						var sideMatch  = checkSideGem(posible1,curent_obje2)
						var sideMatch2 = checkSideGem(posible2,curent_obje1)
						if sideMatch != null:
							targetCol = sideMatch[0][0]
							isRotate = true
							rotCount = 1
							clockWise = sideMatch[1] == "r"
						elif sideMatch2 != null:
							targetCol = sideMatch2[0][0]
							if sideMatch2[1] == "r":
								targetCol = targetCol+1
								clockWise = false
							else:
								targetCol = targetCol-1
								clockWise = true
							isRotate = true
							rotCount = 1
						else:
							# Ser random 
							if [0,1][randi() % 2] == 0:
								#select first
								tmp_cols = posible1[randi() % posible1.size()][0]
								targetCol = tmp_cols
							else:
								#select second
								tmp_cols = posible2[randi() % posible2.size()][0]
								targetCol = tmp_cols
								isRotate = true
								rotCount = 2
								if tmp_cols > 3:
									clockWise = false
						
	elif posible1.size() != 0:
		
		var crossMatchCol = checkTopCrossGem(posible1)
		if crossMatchCol == null:
			#check same color of pair gem in grid
			var isGemSameAsPair = checkSameAsPair()
			if isGemSameAsPair != null:
				tmp_cols = isGemSameAsPair[0]
				targetCol = tmp_cols
				if isGemSameAsPair[1] == "y":
					isRotate = true
					rotCount = 2
					if tmp_cols > 3:
						clockWise = false
			else:
				# Check seond gem match of left-right same targetcol
				var sideMatch = checkSideGem(posible1,curent_obje2)
				if sideMatch != null:
					targetCol = sideMatch[0][0]
					isRotate = true
					rotCount = 1
					clockWise = sideMatch[1] == "r"
				else:
					randomize()
					tmp_cols = posible1[randi() % posible1.size()][0]
					targetCol = tmp_cols
		else:
			targetCol = crossMatchCol
	
	elif posible2.size() != 0:
		
		var updateRotation = true
		var crossMatchCol = checkTopCrossGem(posible2)
		if crossMatchCol == null:
			#check same color of pair gem in grid
			var isGemSameAsPair = checkSameAsPair()
			if isGemSameAsPair != null:
				tmp_cols = isGemSameAsPair[0]
				targetCol = tmp_cols
				isRotate = isGemSameAsPair[1] == "y"
				rotCount = 2
				if tmp_cols > 3:
					clockWise = false
				updateRotation = false
			else:
				# Check seond gem match of left-right same targetcol
				var sideMatch = checkSideGem(posible2,curent_obje1)
				if sideMatch != null:
					targetCol = sideMatch[0][0]
					if sideMatch[1] == "r":
						targetCol = targetCol+1
						clockWise = false
					else:
						targetCol = targetCol-1
						clockWise = true
					isRotate = true
					rotCount = 1
					updateRotation = false
				else:
					randomize()
					tmp_cols = posible2[randi() % posible2.size()][0]
					targetCol = tmp_cols
		else:
			targetCol = crossMatchCol
			tmp_cols  = crossMatchCol
		if updateRotation:
			isRotate = true
			rotCount = 2
			if tmp_cols > 3:
				clockWise = false
	else:
		# Check Side gem Match 
		var posibleSide1 = check_available_pos(curent_obje1,true)
		if posibleSide1.size() != 0:
			randomize()
			tmp_cols = posibleSide1[randi() % posibleSide1.size()][0]
			targetCol = tmp_cols
		else:	
			var posibleSide2 = check_available_pos(curent_obje2,true)
			if posibleSide2.size() != 0:
				randomize()
				tmp_cols = posibleSide2[randi() % posibleSide2.size()][0]
				targetCol = tmp_cols
				isRotate = true
				rotCount = 2
				if tmp_cols > 3:
					clockWise = false
	
	
	# Check diamond gem in pair
	var diamindInPair = checkDiamondInPair()
	if diamindInPair[0]:
		var colorCount = allColorCount()
		var maxGemIndex = colorCount.find(colorCount.max())
		var targetColor = "pink"
		if maxGemIndex == 1:
			targetColor = "blue"
		elif maxGemIndex == 2:
			targetColor = "green"
		elif maxGemIndex == 3:
			targetColor = "yellow"
		index = 0
		for row in cols_counts:
			if row != 0:
				if all_pieces[index][row-1].color == targetColor:
					targetCol = index
					break
			index = index + 1
		if index == 6:
			colorCount[maxGemIndex] = 0
			var maxGemIndex2 = colorCount.find(colorCount.max())
			targetColor = "pink"
			if maxGemIndex2 == 1:
				targetColor = "blue"
			elif maxGemIndex2 == 2:
				targetColor = "green"
			elif maxGemIndex2 == 3:
				targetColor = "yellow"
			index = 0
			for row in cols_counts:
				if row != 0:
					if all_pieces[index][row-1].color == targetColor:
						targetCol = index
						break
				index = index + 1
				
		if diamindInPair[1] == "2" && index != 6: # 6 means not any gem in grid
			isRotate = true
			rotCount = 2
			if targetCol > 3:
				clockWise = false
		else:
			isRotate = false
			
	if (targetCol - 3) < 0 :
		var x = 3
		while(x != targetCol):
			if curent_obje2 != null and curent_obje1 != null && !isCurentPairBreak:
				move_piece_left_right(true)
			x = x - 1
			var t = Timer.new()
			t.set_wait_time(AI_ANIM_TIME)
			t.set_one_shot(true)
			self.add_child(t)
			t.start()
			yield(t, "timeout")
			t.queue_free()
	elif (targetCol - 3) > 0 :
		var x = 3
		while(x < targetCol):
			if curent_obje2 != null and curent_obje1 != null && !isCurentPairBreak:
				move_piece_left_right(false)
			x = x + 1
			var t = Timer.new()
			t.set_wait_time(AI_ANIM_TIME)
			t.set_one_shot(true)
			self.add_child(t)
			t.start()
			yield(t, "timeout")
			t.queue_free()
	
	if isRotate:
		var x = 0
		while(x<rotCount):
			if !isCurentPairBreak:
				rotate_piece_(clockWise)
			else:
				break
			var t = Timer.new()
			t.set_wait_time(AI_ANIM_TIME)
			t.set_one_shot(true)
			self.add_child(t)
			t.start()
			yield(t, "timeout")
			t.queue_free()
			x += 1
	
	if gmMode == GLOBAL.GameMode.HARD:
		var flagger = [true,false]
		isDropedIn = flagger[randi() % flagger.size()]
		var t = Timer.new()
		t.set_wait_time(0.1)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
		t.queue_free()
		isDropedIn = false
		
	pass

func checkSideGem(arr_posible,gem_obj):
	for pos in arr_posible:
		var col = pos[0]
		if col != 0:
			var lpos = cols_counts[col-1]
			if lpos < height && all_pieces[col][lpos] != null && all_pieces[col][lpos].color == gem_obj.color:
				return [pos,"l"]
		if col != 5:
			var rpos = cols_counts[col+1]
			if rpos < height && all_pieces[col][rpos] != null && all_pieces[col][rpos].color == gem_obj.color:
				return [pos,"r"]
	pass

func checkSameAsPair():
	for col in finalArray:
		var cpos = cols_counts[col]
		# Left side check
		if not isCheckCell(col-1,cpos) && not isCheckCell(col-1,cpos+1):
			if all_pieces[col-1][cpos].color == curent_obje1.color && all_pieces[col-1][cpos+1].color == curent_obje2.color:
				return [col,"n"]
			elif all_pieces[col-1][cpos].color == curent_obje2.color && all_pieces[col-1][cpos+1].color == curent_obje1.color:
				return [col,"y"]
		# Right side check
		if not isCheckCell(col+1,cpos) && not isCheckCell(col+1,cpos+1):
			if all_pieces[col+1][cpos].color == curent_obje1.color && all_pieces[col+1][cpos+1].color == curent_obje2.color:
				return [col,"n"]
			elif all_pieces[col+1][cpos].color == curent_obje2.color && all_pieces[col+1][cpos+1].color == curent_obje1.color:
				return [col,"y"]

			
func checkTopCrossGem(arr_posible):
	var isCrossMatch = false
	for point in arr_posible:
		var i = point[0]
		var j = point[1]
		# Top left check
		if i != 0 && all_pieces[i-1][j+1] != null && all_pieces[i-1][j+1].color == all_pieces[i][j].color:
			isCrossMatch = true
			return i

		# Top Right check
		if i != 5 && all_pieces[i+1][j+1] != null && all_pieces[i+1][j+1].color == all_pieces[i][j].color:
			isCrossMatch = true
			return i
	
	if !isCrossMatch:
		return null	

func check_available_pos(obj,isSideCheck = false):
	var availPos = []
	for i in width:
		if not finalArray.has(i):
			continue
		for j in height:
			if all_pieces[i][j] == null:
				if j < height - 3:
					availPos.append([i,j])
				break
	return select_most_matchingPos(availPos,obj,isSideCheck)

func select_most_matchingPos(arr_pos, gemObj, isSideCheck):
	var restArray = []
	if isSideCheck:
		for pos in arr_pos:
			# Right side check
			if not isCheckCell(pos[0]+1,pos[1]):
				if all_pieces[pos[0]+1][pos[1]].color == gemObj.color:
					restArray.append([pos[0],pos[1]-1])
			# Left Side check
			elif not isCheckCell(pos[0]-1,pos[1]):
				if all_pieces[pos[0]-1][pos[1]].color == gemObj.color:
					restArray.append([pos[0],pos[1]-1])
	else:
		for pos in arr_pos:
			#Check Below Piece
			if not isCheckCell(pos[0],pos[1]-1):
				if all_pieces[pos[0]][pos[1]-1].color == gemObj.color:
					restArray.append([pos[0],pos[1]-1])
					
	return restArray

func isCheckCell(row,column):
	if row >= width or row < 0  or column >= height or column < 0:
		return true
	if all_pieces[row][column] == null:
		return true
	return false

func checkCellValid(x,y):
	if x >= width or x < 0  or y >= height or y < 0:
		return false
	if all_pieces[x][y] != null:
		return true
	return false

func checkFullSameColor(arr_col):
	for col in arr_col:
		var row = cols_counts[col] - 1
		var count = 0
		var topGem = all_pieces[col][row]
		for val in range(row,-1,-1):
			if all_pieces[col][val].color == topGem.color:
				count = count + 1
				if count > 3:
					print("Full col of same color")
					return true
	return false
	
func allColorCount():
	var red = 0
	var blue = 0
	var green = 0
	var yellow = 0
	for i in width:
		for j in height:
			var gem = all_pieces[i][j]
			if gem == null:
				break
			else:
				if gem.color == "pink":
					red = red + 1
				elif gem.color == "blue":
					blue = blue + 1
				elif gem.color == "green":
					green = green + 1
				elif gem.color == "yellow":
					yellow = yellow + 1
	return [red,blue,green,yellow]
	
func check_for_ExpertMODE():
	if curent_obje1 != null && curent_obje2 != null :
		var isSame = curent_obje1.color == curent_obje2.color
		var matchData1 = []
		var matchData2 = []
		for i in width:
			for j in height:
				if all_pieces[i][j] != null:
					if isSame :
						if all_pieces[i][j].color == curent_obje1.color :
							#matchData1.append([i,j])
							if i == 0 :
								if all_pieces[i+1][j] == null:
									if j != 0:
										if all_pieces[i+1][j-1] != null:
											matchData1.append([i+1,j])
							elif i == width-1 :
								if all_pieces[i-1][j] == null:
									if j != 0:
										if all_pieces[i-1][j-1] != null:
											matchData1.append([i-1,j])
							else:
								if all_pieces[i+1][j] == null:
									if j != 0:
										if all_pieces[i+1][j-1] != null:
											matchData1.append([i+1,j])
								if all_pieces[i-1][j] == null:
									if j != 0:
										if all_pieces[i-1][j-1] != null:
											matchData1.append([i-1,j])
								
					else:
						if all_pieces[i][j].color == curent_obje1.color :
							if i == 0 :
								if all_pieces[i+1][j] == null:
									if j != 0:
										if all_pieces[i+1][j-1] != null:
											matchData1.append([i+1,j])
							elif i == width-1 :
								if all_pieces[i-1][j] == null:
									if j != 0:
										if all_pieces[i-1][j-1] != null:
											matchData1.append([i-1,j])
							else:
								if all_pieces[i+1][j] == null:
									if j != 0:
										if all_pieces[i+1][j-1] != null:
											matchData1.append([i+1,j])
								if all_pieces[i-1][j] == null:
									if j != 0:
										if all_pieces[i-1][j-1] != null:
											matchData1.append([i-1,j])
						elif all_pieces[i][j].color == curent_obje2.color:
							if i == 0 :
								if all_pieces[i+1][j] == null:
									if j != 0:
										if all_pieces[i+1][j-1] != null:
											matchData2.append([i+1,j])
							elif i == width-1 :
								if all_pieces[i-1][j] == null:
									if j != 0:
										if all_pieces[i-1][j-1] != null:
											matchData2.append([i-1,j])
							else:
								if all_pieces[i+1][j] == null:
									if j != 0:
										if all_pieces[i+1][j-1] != null:
											matchData2.append([i+1,j])
								if all_pieces[i-1][j] == null:
									if j != 0:
										if all_pieces[i-1][j-1] != null:
											matchData2.append([i-1,j])
		
		randomize()
		
		if matchData1.size() == 0 && matchData2.size() == 0:
			return []
		
		if matchData1.size() == 0 && matchData2.size() != 0:
			var colsNm = matchData2[randi() % matchData2.size()]
			return [colsNm[0],true]
		elif matchData2.size() == 0 && matchData1.size() != 0:
			var colsNm = matchData1[randi() % matchData1.size()]
			return [colsNm[0],false]
		elif matchData1.size() > matchData2.size():
			var colsNm = matchData1[randi() % matchData1.size()]
			if colsNm[0] == 3 and matchData1.size() > 1:
				colsNm = matchData1[randi() % matchData1.size()]
			return [colsNm[0],false]
		else: 
			var colsNm = matchData2[randi() % matchData2.size()]
			if colsNm[0] == 3 and matchData2.size() > 1:
				colsNm = matchData2[randi() % matchData2.size()]
			return [colsNm[0],true]
	return []

func _on_red_pressed():
	GLOBAL.selectColor = "r"
	pass # Replace with function body.


func _on_yellow_pressed():
	GLOBAL.selectColor = "y"
	pass # Replace with function body.


func _on_blue_pressed():
	GLOBAL.selectColor = "b"
	pass # Replace with function body.


func _on_green_pressed():
	GLOBAL.selectColor = "g"
	pass # Replace with function body.


func _on_toggleCouter_pressed():
	if GLOBAL.isCrashOn == "n":
		GLOBAL.isCrashOn = "c"
		$Control/toggleCouter.text = "Crash Gem"
	else:
		GLOBAL.isCrashOn = "n"
		$Control/toggleCouter.text = "Normal Gem"
	pass # Replace with function body.

var arr = ["r","y","b","g"]
var index = 0
func _on_gem1_pressed():
	index = (index + 1)%4
	$Control/lbl1.text = arr[index]
	pass # Replace with function body.


func _on_gem2_pressed():
	index = (index + 1)%4
	$Control/lbl2.text = arr[index]
	pass # Replace with function body.


func _on_Reset_pressed():
	all_pieces
	pass # Replace with function body.







#func call_AI():
#
#	isAICalled = true	
#	var rotCount = 0
#	var clockWise = true
#	var isRotate = false
#	var count = 12
#	var tmp_cols = 0
#	var prev_selct_cols = 0
#
#	get_valid_columns()
#
#	for item in arr_cols_counts:
#		if item[1] < count:
#			count = item[1]
#			tmp_cols = item[0]
#		if count > 9:
#			AI_ANIM_TIME = 0.02
#			#if cols_Array.has(3):
#			#	cols_Array.remove(5)
#
#	prev_selct_cols = tmp_cols
#	var targetCol = tmp_cols
#
#	var posible1 = check_available_pos(curent_obje1)
#	var posible2 = check_available_pos(curent_obje2)
#	if posible1.size() != 0 && posible2.size() != 0:
#		randomize()
#		if curent_obje1.color == curent_obje2.color :
#			#check for same in width:
#			var arr_posSame = []
#			var pItem 
#
#			for item in posible1:
#				if pItem != null:
#					if pItem[1] == item[1] && item[0]-pItem[0] == 1 :
#						arr_posSame.append(item[0])
#				pItem = item
#			if arr_posSame.size() != 0:
#				targetCol = arr_posSame[0] #arr_posSame[arr_posSame.size()-1]
#				isRotate = true
#				clockWise = false
#				rotCount = 1
#				if arr_posSame.size() > 1:
#					if cols_counts[arr_posSame[0]] > 8 && cols_counts[arr_posSame[1]] < 8:
#						targetCol = arr_posSame[1]
#				print("select ",targetCol)
#			else:
#				#check in each column
#				var isTriangal = false
#				for x in cols_Array:
#					var isSideMatch = false
#					var lc = 0
#					var rc = 0
#					for point in range(cols_counts[x],height):
#						var rMatch = false
#						var lMatch = false
#						if x != 5 && all_pieces[x+1][point] != null && all_pieces[x+1][point].color == curent_obje1.color:
#								rMatch = true
#								rc += 1
#								if !isTriangal:
#									targetCol = x
#									isTriangal = true
#
#						if x != 0 && all_pieces[x-1][point] != null && all_pieces[x-1][point].color == curent_obje1.color:
#								lMatch = true
#								lc += 1
#								if !isTriangal:
#									targetCol = x
#									isTriangal = true
#
#						if not rMatch and not lMatch:
#							break
#						elif lc >= 2 || rc >= 2:
#							targetCol = x
#							isSideMatch = true
#							break
#					if isSideMatch:
#						break						
#				if !isTriangal:
#					targetCol = posible1[0][0]
#
#		else:
#			# Check 
#			var isGetSameGem_AsPair = false
#			var posible1_Order = []
#			var posible2_Order = []
#			for col in cols_Array:
#				for pCol in posible1:
#					if pCol[0] == col:
#						posible1_Order.append(pCol)
#				for pCol in posible2:
#					if pCol[0] == col:
#						posible2_Order.append(pCol)
#
#			for point in posible1_Order:
#				var col = point[0]
#				for xPoint in posible2_Order:
#					# Left side match
#					if xPoint[0] == col-1:
#						targetCol = col
#						isRotate = true
#						rotCount = 1
#						clockWise = false
#						isGetSameGem_AsPair = true
#						break
#					# Right side match
#					elif xPoint[0] == col + 1:
#						targetCol = col
#						isRotate = true
#						rotCount = 1
#						clockWise = true
#						isGetSameGem_AsPair = true
#						break
#				if isGetSameGem_AsPair:
#					break
#			if !isGetSameGem_AsPair:		
#				if [0,1][randi() % 2] == 0:
#					#select first
#					tmp_cols = posible1[randi() % posible1.size()][0]
#					targetCol = tmp_cols
#				else:
#					#select second
#					tmp_cols = posible2[randi() % posible2.size()][0]
#					targetCol = tmp_cols
#					isRotate = true
#					rotCount = 2
#					if tmp_cols > 3:
#						clockWise = false
#
#	elif posible1.size() != 0:
#		randomize()
#		tmp_cols = posible1[randi() % posible1.size()][0]
#		targetCol = tmp_cols
#
##		if randi() % 2 == 1:
##			if tmp_cols > 3:
##				isRotate = true
##				clockWise = false
##				rotCount = 1
##			elif tmp_cols <= 3:
##				isRotate = true
##				rotCount = 1
##				if tmp_cols < 5:
##					targetCol = tmp_cols + 1
#
#	elif posible2.size() != 0:
#		randomize()
#		tmp_cols = posible2[randi() % posible2.size()][0]
#		targetCol = tmp_cols
#		isRotate = true
#		rotCount = 2
##		if randi() % 2 == 1:
#		if tmp_cols > 3:
#			clockWise = false
#
#	else:
#		# Check Side gem Match 
#		var posibleSide1 = check_available_pos(curent_obje1,true)
#		if posibleSide1.size() != 0:
#			randomize()
#			tmp_cols = posibleSide1[randi() % posibleSide1.size()][0]
#			targetCol = tmp_cols
#		else:	
#			var posibleSide2 = check_available_pos(curent_obje2,true)
#			if posibleSide2.size() != 0:
#				randomize()
#				tmp_cols = posibleSide2[randi() % posibleSide2.size()][0]
#				targetCol = tmp_cols
#				isRotate = true
#				rotCount = 2
#				if tmp_cols > 3:
#					clockWise = false
#
#
##	if gmMode == GLOBAL.GameMode.EASY:
##		randomize()
##		if [0,1][randi() % 2] == 0:
##			targetCol = prev_selct_cols
#
##	var filledCols = 0
##	for item in arr_cols_counts:
##		if item[1] >= 8:
##			filledCols =+ 1
##	if  filledCols >= 4:
##		targetCol = prev_selct_cols
##	else:
##		if cols_Array[cols_Array.size()-1] >= 9:
##			targetCol = prev_selct_cols
#
#	# Check diamond gem in pair
#	if checkDiamondInPair():
#		isRotate = true
#		rotCount = 2
#		if targetCol > 3:
#			clockWise = false
#
#	if (targetCol - 3) < 0 :
#		var x = 3
#		while(x != targetCol):
#			if curent_obje2 != null and curent_obje1 != null && !isCurentPairBreak:
#				move_piece_left_right(true)
#			x = x - 1
#			var t = Timer.new()
#			t.set_wait_time(AI_ANIM_TIME)
#			t.set_one_shot(true)
#			self.add_child(t)
#			t.start()
#			yield(t, "timeout")
#	elif (targetCol - 3) > 0 :
#		var x = 3
#		while(x < targetCol):
#			if curent_obje2 != null and curent_obje1 != null && !isCurentPairBreak:
#				move_piece_left_right(false)
#			x = x + 1
#			var t = Timer.new()
#			t.set_wait_time(AI_ANIM_TIME)
#			t.set_one_shot(true)
#			self.add_child(t)
#			t.start()
#			yield(t, "timeout")
#
#	if isRotate:
#		var x = 0
#		while(x<rotCount):
#			if !isCurentPairBreak:
#				rotate_piece_(clockWise)
#			else:
#				break
#			var t = Timer.new()
#			t.set_wait_time(AI_ANIM_TIME)
#			t.set_one_shot(true)
#			self.add_child(t)
#			t.start()
#			yield(t, "timeout")
#			x += 1
#
#	if gmMode == GLOBAL.GameMode.HARD:
#		var flagger = [true,false]
#		isDropedIn = flagger[randi() % flagger.size()]
#	pass