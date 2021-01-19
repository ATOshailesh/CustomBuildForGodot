extends "res://scripts/main/Grid.gd"

# To manage AI operation once per pair
var AI_ANIM_TIME = 0.09
var PlaceHolder = preload("res://scenes/pieces/Dot_Piece.tscn")

func _ready():
	._ready()
	playerType = GLOBAL.PlayerMode.AI
	#Playing with other player in same machine
#	if not GLOBAL.isNetworked:

	if GLOBAL.isNetworked:
		isCanPlaySound = false
		playerType = GLOBAL.PlayerMode.PLAYER
		
		if NetCmd.isPaired:
			playerType = GLOBAL.PlayerMode.NONE
		
		if playerType == GLOBAL.PlayerMode.PLAYER:
			playerNo = 2
#	else:
#		pairManager = GLOBAL.pairManager
		pass
	showNextPair()
	get_columnNCounts()
	#spawn_pieces()
	pass

func _input(event):
	if event.is_action_pressed("spawn_pair"):
		print("KL")
		emit_signal("GameOver")
	if event.is_action_pressed("send_counter"):
		print("send counter to grid1")
		emit_signal("SendCounterGem",2)

func spawn_pieces():
	for i in width:
		for j in height:
			var piece = PlaceHolder.instance()
			add_child(piece)
			piece.position = gemEngine.grid_to_pixel(i,j)
			
func getCounterPattern(index):
	counterPatternGenret(index)

func call_AI_func():
	call_AI()
	pass

func spaw_pair_from_top(isP1=true):
	if not gemEngine.isGemRemoved:
		_update_score(10)
	.spaw_pair_from_top(false)
	isAICalled = false
	.showNextPair(false)
	
	if GLOBAL.isNetworked && NetCmd.isPaired:
		if curent_obje1 != null && curent_obje2 != null:
			get_node(curent_obje1.name).position.y = get_node(curent_obje1.name).position.y + 30
			get_node(curent_obje2.name).position.y = get_node(curent_obje2.name).position.y + 30
	
	get_parent().get_parent().update_P2Score($lblScore.text)

func get_piece_FixPosition():
	.get_piece_FixPosition()
	get_columnNCounts()

func showNextPair(isP1=false):
	print("p2")
	.showNextPair(false)
	

func _dropNewPair_Timer_Out():
	._dropNewPair_Timer_Out()
	if isCGemToFall:
		#Drop Counter Gems:
		isCGemToFall = false
		_makeCounterGem()
	else:
		if not GLOBAL.isNetworked:
			if checkColumnDrop():
				spaw_pair_from_top()

func showYouWin():
	.showYouWin()


####
#### Call this function after pair entered in Scene
#### : call_AI()():

var cols_counts = []
var arr_cols_counts = []
var cols_pattern = [0,5,1,2,4,3]
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
	for col in cols_pattern:
		if finalArray.has(col):
			tamp_colsArray.append(col)
	cols_Array = tamp_colsArray
	get_columnNCounts()

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
				#print("Group size",all_pieces[arr_posSame[0][cols_counts[arr_posSame[0]]]].groupSize)
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
		var index = 0
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
		t.set_wait_time(0.05)
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


#func check_available_pos(obj,isSideCheck = false):
#	var availPos = []
#	for i in width:
#		if not finalArray.has(i):
#			continue
#		var j = height - 1
#		while j > 0: 
#		#for j in height:
#			if all_pieces[i][j-1] != null:
#				if j < height - 2:
#					availPos.append([i,j])
#				break
#			j -= 1
#	return select_most_matchingPos(availPos,obj,isSideCheck)

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