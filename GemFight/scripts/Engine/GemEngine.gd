extends Node

class GemEngine:
	
	signal boomAnime
	signal dropAnime
	signal timeAnime
	signal showChain
	signal _newPair_Emit
	signal _gem_crashed
	signal wait_to_normal
	signal create_power_gem
	signal _show_score
	signal _show_power_gem_score
	
	var arr_crash_gems = []
	var all_pieces = []
	var height
	var width
	var x_start
	var y_start
	var offset
	var chainReactionCount = 0
	var groupId = 0
	var scrManager
	var isGemRemoved = true
	
	func _init(_inp_array,_height,_width,_x_start,_y_start,_offset):
		all_pieces = _inp_array
		height = _height
		width = _width
		x_start = _x_start
		y_start = _y_start
		offset = _offset
	
	
	func grid_to_pixel(column, row):
		var new_x = x_start + offset * column;
		var new_y = y_start + -offset * row;
		return Vector2(new_x, new_y);

	func pixel_to_grid(pixel_x, pixel_y):
		var new_x = round((pixel_x - x_start) / offset);
		var new_y = round((pixel_y - y_start) / -offset);
		return Vector2(new_x, new_y);
	
	func pixel_to_grid2(pixel_x, pixel_y):
		var new_x = floor((pixel_x - x_start) / offset);
		var new_y = floor((pixel_y - y_start) / -offset);
		return Vector2(new_x, new_y);
	
	
	func clear_piece_match_Filter():
		for i in width:
			for j in height:
				if all_pieces[i][j] != null:
					all_pieces[i][j].matched = false
	
	
	func fire_findMatrix(isDiamond):
		isGemRemoved = false
		chainReactionCount = 0
		#reset crash gem array
		arr_crash_gems = []
		var isWait = false
		
		for i in width:
			for j in height:
				if all_pieces[i][j] != null:
					var tmpNode = all_pieces[i][j]
					tmpNode.get_node(".").position = grid_to_pixel(i,j)
					tmpNode.myPos = Vector2(i,j)
					if tmpNode.gemType == GLOBAL.GemTypes.CRASH:
						arr_crash_gems.append(tmpNode)
					if tmpNode.gemType == GLOBAL.GemTypes.COUNTER:
						tmpNode.changeToNormalGem()
						if tmpNode.gemType == GLOBAL.GemTypes.NORMAL:
							isWait = true
		
		if isWait:
			emit_signal("wait_to_normal",isDiamond)
		else:
			emit_signal("wait_to_normal",isDiamond,0.2)
#			if isDiamond != null:
#				diamon_removeMatchColor(isDiamond)
#			else:
#				find_matrix()
	
	func gem_Converted(isDiamond):
		if isDiamond != null:
			diamon_removeMatchColor(isDiamond)
		else:
			find_matrix()
	
	
	func diamon_removeMatchColor(diamonGemIn):
		var pos = diamonGemIn.myPos
		if pos.y != 0:
			var cCount = 0
			chainReactionCount += 1 
			diamonGemIn.removeFromParent()
			diamonGemIn = null
			all_pieces[pos.x][pos.y] = null
			var cGem = all_pieces[pos.x][pos.y-1]
			for i in width:
				for j in height:
					if all_pieces[i][j] != null :
						if all_pieces[i][j].color == cGem.color:
							emit_signal("boomAnime",all_pieces[i][j].position)
							all_pieces[i][j].removeFromParent()
							all_pieces[i][j] = null
							cCount += 1 
			var tmpCrash = []
			for item in arr_crash_gems:
				if item.color != cGem.color:
					tmpCrash.append(item)
			arr_crash_gems = []
			arr_crash_gems = tmpCrash
			isPowerGemOn = true
			emit_signal("_gem_crashed",cCount)
			reArrange_pieces([0,1,2,3,4,5])
		else:
			emit_signal("boomAnime",all_pieces[pos.x][pos.y].position)
			all_pieces[pos.x][pos.y] = null
			diamonGemIn.removeFromParent()
			find_matrix()
			crash_find_n_destroy()
			reArrange_pieces([pos.x])
			emit_signal("_gem_crashed",1)
	
	
	func find_matrix():
		clear_piece_match_Filter()
		for i in width-1:
			for j in height-1:
				var cNode = all_pieces[i][j]
				var rNode = all_pieces[i+1][j]
				var tNode = all_pieces[i][j+1]
				
				if cNode != null :
					if cNode.isGrouped == 0:
						if rNode != null and tNode != null:
							#gemType = GLOBAL.GemTypes.NORMAL
							if cNode.gemType == GLOBAL.GemTypes.NORMAL and cNode.color == rNode.color and cNode.color == tNode.color and !cNode.matched and rNode.isGrouped == 0 and tNode.isGrouped == 0:
								if rNode.gemType == GLOBAL.GemTypes.NORMAL and tNode.gemType == GLOBAL.GemTypes.NORMAL:
									find_min_max_matrix(i,j)
					else:
						if !cNode.matched:
							change_matched_for(i,j)
							checkIncreseGroup(i,j)
		go_to_groupMatch()
		crash_find_n_destroy()
	
	func find_min_max_matrix(posX,posY):
		var rMax = posX
		var color = all_pieces[posX][posY].color
		while(rMax < width):
			if all_pieces[rMax][posY] != null:
				if all_pieces[rMax][posY].color == color && all_pieces[rMax][posY].isGrouped == 0 && !all_pieces[rMax][posY].matched && all_pieces[rMax][posY].gemType == GLOBAL.GemTypes.NORMAL:
					rMax = rMax+1
				else:
					break
			else:
				break
		
		var cMax = posY
		while(cMax<height):
			if all_pieces[posX][cMax] != null:
				if all_pieces[posX][cMax].color == color && all_pieces[posX][cMax].isGrouped == 0 && !all_pieces[posX][cMax].matched && all_pieces[posX][cMax].gemType == GLOBAL.GemTypes.NORMAL:
					cMax = cMax+1
				else:
					break
			else:
				break
		
		var isMatrix = true
		var isFoundNull = false
		var tmpVec = Vector2(0,0)
		
		for i in range(posX,rMax):
			for j in range(posY,cMax):
				if all_pieces[i][j] != null:
					if all_pieces[i][j].color != color || all_pieces[i][j].isGrouped != 0 || all_pieces[i][j].gemType != GLOBAL.GemTypes.NORMAL:
						isMatrix = false
						tmpVec = Vector2(i,j)
						isFoundNull = true
						break
				else:
					isMatrix = false
					isFoundNull = true
					tmpVec = Vector2(i,j)
					break
			if isFoundNull:
				break
		
		if isFoundNull:
			filter_tmp_pieces(posX,posY,rMax,cMax,color,tmpVec)
		
		if isMatrix:
			applyColorEffect(posX,posY,rMax,cMax)


	func filter_tmp_pieces(row,col,rMax,cMax,cVal,nullAt):
		var matrixSize = Vector2(rMax-row,cMax-col)
		# Check in which direction we have check from minimum match
		
		var newHeight = matrixSize.y
		var p = 0
		for x in range(row,rMax):
			var t = 0
			var isBreaked = false
			for j in range(col,cMax):
				if all_pieces[x][j] != null:
					if all_pieces[x][j].color == cVal && all_pieces[x][j].gemType == GLOBAL.GemTypes.NORMAL:
						t = t + 1
					else:
						isBreaked = true
						break
				else:
					isBreaked = true
					break
					
			if t >= 2:
				if newHeight >= t:
					newHeight = t
				p = p + 1
			else:
				break
			if isBreaked:
				break
	
		
		var newRMax = rMax - (matrixSize.x - p)
		var newCMax = cMax - (matrixSize.y - newHeight)
		if p >= 2 :
			var isMatrix = true
			for x in range(row,newRMax):
				for y in range(col,newCMax):
					if all_pieces[x][y] != null:
						if all_pieces[x][y].color != cVal || all_pieces[x][y].isGrouped != 0 || all_pieces[x][y].matched || all_pieces[x][y].gemType != GLOBAL.GemTypes.NORMAL:
							isMatrix = false
					else:
						isMatrix = false
			if isMatrix:
				applyColorEffect(row,col,newRMax,newCMax)
		pass


	# Apply groupping Color as poweGem
	func applyColorEffect(x,y,widVal,colVal):
		groupId += 1 
		var effectColor = generateRandomColor()
		var mSize = Vector2(widVal-x,colVal-y)
		for i in range(x,widVal):
			for j in range(y,colVal):
				all_pieces[i][j].matched   = true
				all_pieces[i][j].isGrouped = groupId
				all_pieces[i][j].groupSize = mSize
				all_pieces[i][j].animColor(effectColor)
		
		
		for item in all_pieces[x][y].get_children():
			if "PowerGemBase" in item.name:
				item.removeFromParent()
				#break
		emit_signal("create_power_gem",all_pieces[x][y].position,all_pieces[x][y].groupSize,all_pieces[x][y].color)
		
	
	func applyColorEffectNSize(x,y,widVal,colVal):
		var effectColor = generateRandomColor()
		var mSize = Vector2(widVal-x,colVal-y)
		for i in range(x,widVal):
			for j in range(y,colVal):
				all_pieces[i][j].isGrouped = all_pieces[x][y].isGrouped
				all_pieces[i][j].matched   = true
				all_pieces[i][j].groupSize = mSize
				all_pieces[i][j].animColor(effectColor)
		

		for item in all_pieces[x][y].get_children():
			if "PowerGemBase" in item.name:
				item.removeFromParent()
				#break
		emit_signal("create_power_gem",all_pieces[x][y].position,all_pieces[x][y].groupSize,all_pieces[x][y].color)
		
		pass
	
	func generateRandomColor():
		randomize()
		var r = float(rand_range(0,255)/255)
		var g = float(rand_range(0,255)/255)
		var b = float(rand_range(0,255)/255)
		return Color(r,g,b,1.0)
	
	func change_matched_for(i,j):
		var matSize = all_pieces[i][j].groupSize
		for a in range(i,i+matSize.x):
			var isNull = false
			for b in range(j,j+matSize.y):
				if all_pieces[a][b] != null:
					if all_pieces[a][b].isGrouped != 0:
						all_pieces[a][b].matched = true
				else:
					isNull = true
					break
			if isNull:
				break
	
	func checkIncreseGroup(i,j):
		var rMatch = checkRightOfGroup(i,j)
		var tMatch = checkTopOfGroup(i,j)
		var lMatch = checkLeftOfGroup(i,j)
		var bMatch = checkBottomOfGroup(i,j)
		
		if rMatch:
			checkIncreseGroup(i,j)
		
		if tMatch: 
			checkIncreseGroup(i,j)
		
		if lMatch:
			checkLeftOfGroup(i-1,j)
			
		if bMatch:
			checkBottomOfGroup(i,j)
		pass
	
	func checkRightOfGroup(i,j):
		var matSize = all_pieces[i][j].groupSize
		var pos = all_pieces[i][j].myPos
		if i + matSize.x >= width:
			return false
			
		var isMatch = true
		var endX = i+matSize.x-1
		var xNode = all_pieces[endX][j]
		var rNode = all_pieces[endX+1][j]
		
		if xNode != null and rNode != null:
			if xNode.color == rNode.color && rNode.isGrouped == 0 && rNode.gemType == GLOBAL.GemTypes.NORMAL:
				for x in range(j,j+matSize.y):
					if all_pieces[endX+1][x] == null:
						isMatch = false
						break
					else:
						if all_pieces[endX+1][x].color != xNode.color or all_pieces[endX+1][x].isGrouped != 0 or all_pieces[endX+1][x].gemType != GLOBAL.GemTypes.NORMAL:
							isMatch = false
							break
			else:
				isMatch = false
		else:
			isMatch = false
		
		if isMatch:
			var sP = endX+1
			var upTo = j+matSize.y-1
			for x in range(j,upTo):
				all_pieces[sP][x].isGrouped = xNode.isGrouped
				all_pieces[sP][x].matched = true
			applyColorEffectNSize(i,j,i+matSize.x+1,matSize.y+j)
		
		return isMatch
		pass

	func checkTopOfGroup(i,j):
		var matSize = all_pieces[i][j].groupSize
		var pos = all_pieces[i][j].myPos
		if j + matSize.y >= height:
			return false
			
		var isMatch = true
		var endY = j+matSize.y-1
		var xNode = all_pieces[i][endY]
		var tNode = all_pieces[i][endY+1]
		if xNode != null and tNode != null:
			if xNode.color == tNode.color && tNode.isGrouped == 0 && tNode.gemType == GLOBAL.GemTypes.NORMAL:
				for x in range(i,i+matSize.x):
					if all_pieces[x][endY+1] == null:
						isMatch = false
						break
					else:
						if all_pieces[x][endY+1].color != xNode.color or all_pieces[x][endY+1].isGrouped != 0 or all_pieces[x][endY+1].gemType != GLOBAL.GemTypes.NORMAL:
							isMatch = false
							break
			else:
				isMatch = false
		else:
			isMatch = false
		
		if isMatch:
			var sP = endY+1
			var upTo = i+matSize.x-1
			for x in range(i,upTo):
				all_pieces[x][sP].isGrouped = xNode.isGrouped
				all_pieces[x][sP].matched = true
			applyColorEffectNSize(i,j,i+matSize.x,matSize.y+j+1)
		
		return isMatch
		pass
	
	func checkLeftOfGroup(i,j):
		if i == 0:
			return false
		var matSize = all_pieces[i][j].groupSize
		var pos = all_pieces[i][j].myPos
		var isMatch = true
		var endX = i+matSize.x-1
		var xNode = all_pieces[i][j]
		var lNode = all_pieces[i-1][j]
		
		if xNode != null and lNode != null:
			if xNode.color == lNode.color && lNode.isGrouped == 0 && lNode.gemType == GLOBAL.GemTypes.NORMAL:
				for x in range(j,j+matSize.y):
					if all_pieces[i-1][x] == null:
						isMatch = false
						break
					else:
						if all_pieces[i-1][x].color != xNode.color or all_pieces[i-1][x].isGrouped != 0 or all_pieces[i-1][x].gemType != GLOBAL.GemTypes.NORMAL:
							isMatch = false
							break
			else:
				isMatch = false
		else:
			isMatch = false
		
		if isMatch:
			var sP = i-1
			var upTo = j+matSize.y-1
			for x in range(j,upTo):
				all_pieces[sP][x].isGrouped = xNode.isGrouped
				all_pieces[sP][x].matched = true
			applyColorEffectNSize(i-1,j,i+matSize.x,matSize.y+j)
		
		return isMatch
	
	func checkBottomOfGroup(i,j):
		if j == 0:
			return false
		var matSize = all_pieces[i][j].groupSize
		var pos = all_pieces[i][j].myPos
		var isMatch = true
		var endY = j+matSize.y-1
		var xNode = all_pieces[i][j]
		var bNode = all_pieces[i][j-1]
		if xNode != null and bNode != null:
			if xNode.color == bNode.color && bNode.isGrouped == 0 && bNode.gemType == GLOBAL.GemTypes.NORMAL:
				for x in range(i,i+matSize.x):
					if all_pieces[x][j-1] == null:
						isMatch = false
						break
					else:
						if all_pieces[x][j-1].color != xNode.color or all_pieces[x][j-1].isGrouped != 0 or all_pieces[x][j-1].gemType != GLOBAL.GemTypes.NORMAL:
							isMatch = false
							break
			else:
				isMatch = false
		else:
			isMatch = false
		
		if isMatch:
			var sP = j-1
			var upTo = i+matSize.x-1
			for x in range(i,upTo):
				all_pieces[x][sP].isGrouped = xNode.isGrouped
				all_pieces[x][sP].matched = true
			applyColorEffectNSize(i,j-1,i+matSize.x,matSize.y+j)
		
		return isMatch
	
	
	func check_powerGems():
		var gemIDArray = []
		var orignPos = []
		for i in width:
			for j in height:
				if all_pieces[i][j] != null:
					if all_pieces[i][j].isGrouped != 0:
						if not gemIDArray.has(all_pieces[i][j].isGrouped):
							gemIDArray.append(all_pieces[i][j].isGrouped)
		return gemIDArray
	
	
	
	func go_to_groupMatch():
		if check_powerGems().size() <= 1:
			go_for_DropNewPair()
			return
		var allGroups = []
		var matchIds = []
		for i in width:
			for j in height:
				var xNode = all_pieces[i][j]
				if xNode != null:
					if xNode.matched and xNode.isGrouped != 0:
						if !matchIds.has(xNode.isGrouped) :
							allGroups.append(xNode)
							matchIds.append(xNode.isGrouped)
		check_groupCanMerge(allGroups)


	func check_groupCanMerge(allGroups):
		if allGroups.size() == 0:
			return
		var flag = false
		for indexI in allGroups.size():
			for indexJ in allGroups.size():
				if indexI == indexJ:
					break
				var group = allGroups[indexI]
				var nextGroup = allGroups[indexJ]
				if group.color == nextGroup.color:
					if group.myPos.x == nextGroup.myPos.x and group.groupSize.x == nextGroup.groupSize.x:
						if group.myPos.y + group.groupSize.y == nextGroup.myPos.y || nextGroup.myPos.y + nextGroup.groupSize.y == group.myPos.y:
							flag = true
							if group.myPos.y > nextGroup.myPos.y :
								mergeTwoGroup(group,nextGroup)
							else:
								mergeTwoGroup(nextGroup,group)
					elif group.myPos.y == nextGroup.myPos.y and group.groupSize.y == nextGroup.groupSize.y:
						if group.myPos.x + group.groupSize.x == nextGroup.myPos.x || nextGroup.myPos.x + nextGroup.groupSize.x == group.myPos.x:
							flag = true
							if group.myPos.x > nextGroup.myPos.x :
								mergeTwoGroup(group,nextGroup)
							else:
								mergeTwoGroup(nextGroup,group)
		if flag:
			go_to_groupMatch()
		pass
	
	func mergeTwoGroup(tgroup1,bgroup2):
		var effectColor = generateRandomColor()
		var cNode = all_pieces[bgroup2.myPos.x][bgroup2.myPos.y]
		var sPoint = bgroup2.myPos
		var endPoint = Vector2(tgroup1.myPos.x + tgroup1.groupSize.x,tgroup1.myPos.y + tgroup1.groupSize.y)
		var mSize = Vector2(endPoint.x-sPoint.x,endPoint.y-sPoint.y)
		for i in range(sPoint.x,endPoint.x):
			for j in range(sPoint.y,endPoint.y):
				all_pieces[i][j].matched   = true
				all_pieces[i][j].isGrouped = cNode.isGrouped
				all_pieces[i][j].groupSize = mSize
				all_pieces[i][j].animColor(effectColor)
				
				for item in all_pieces[i][j].get_children():
					if "PowerGemBase" in item.name:
						item.removeFromParent()
						#break
		
		emit_signal("create_power_gem",cNode.position,mSize,cNode.color)
		
		pass
	
	
	###
	### Crash Imaplementation
	###
	var arr_crashRemove = []
	var arr_match_node = []
	var arr_match_counter_node = []
	var isPowerGemOn = false 
	
	
	func crash_find_n_destroy():
		arr_crashRemove = []
		arr_match_counter_node = []
		
		var tmp_counter_node = []
		
		if arr_crash_gems.size() != 0 :
			for item in arr_crash_gems:
				var result = destroyNodes(item.myPos.x,item.myPos.y)
				if result.size() > 1:
					tmp_counter_node = tmp_counter_node + arr_match_counter_node
					for ritem in result:
						if not arr_crashRemove.has(ritem) && arr_crash_gems.has(ritem):
							arr_crashRemove.append(ritem)
					arr_match_node = arr_match_node + result
				arr_match_counter_node = []
					
		var arr_node_removed_row = []
		
		arr_match_counter_node = tmp_counter_node
		if arr_crashRemove.size() != 0:
			chainReactionCount += 1
			
		if arr_match_node.size() >= 2:
			var isRemoved = false
			for x in arr_crashRemove:
				arr_crash_gems.erase(x)
				isRemoved = true
			arr_crashRemove = []
			
			#Remove Counter Gem If Any
			if arr_match_counter_node.size() != 0:
				arr_match_node = arr_match_node + arr_match_counter_node
			
			#print("Removed Node Count :",arr_match_node.size())
			emit_signal("_gem_crashed",arr_match_node.size())
			var grpInfo = []
			var arrGrpAdded = []
			var targetPos = self.grid_to_pixel(2,2)
			var n = 0
			var c = 0
			for item in arr_match_node:
				if !arr_node_removed_row.has(item.myPos.x):
					arr_node_removed_row.append(item.myPos.x)
				
				var pice = all_pieces[item.myPos.x][item.myPos.y]
				if pice != null :
					if not arrGrpAdded.has(pice.isGrouped) && pice.isGrouped != 0:
						arrGrpAdded.append(pice.isGrouped)
						grpInfo.append(pice.groupSize)
						targetPos = pice.position
					else:
						match pice.gemType:
							GLOBAL.GemTypes.NORMAL,GLOBAL.GemTypes.COUNTER:
								n += 1
							GLOBAL.GemTypes.CRASH:
								c += 1
				
				emit_signal("boomAnime",item.position)
				all_pieces[item.myPos.x][item.myPos.y] = null
				item.removeFromParent()
			
			var noramlScore = scrManager.input_NormalGem(n)
			var crashScore = scrManager.input_NormalGem(c)
			var powerScore = 0
			for item in grpInfo:
				powerScore += scrManager.input_powerGem(item,1)
			isGemRemoved = true
			if powerScore != 0:
				emit_signal("_show_power_gem_score",powerScore,targetPos)
			emit_signal("_show_score",powerScore+noramlScore+crashScore)
			arr_match_node = []
		
		arr_node_removed_row.sort()
		
		if arr_node_removed_row.size() != 0:
			reArrange_pieces([0,1,2,3,4,5])
		else:
			if chainReactionCount > 1 :
				emit_signal("showChain",chainReactionCount)
			else:
				#print("End Crash:")
				go_for_DropNewPair()


	func destroyNodes(startI,startJ): 
		var tmp_match = [all_pieces[startI][startJ]]
		var index = 0
		while(index < tmp_match.size()):
			if tmp_match[index] != null :
				var point = tmp_match[index].myPos
				var xtmparr = checkAllSide_ForCrash(point.x,point.y)
				for piece in xtmparr:
					if not arr_match_node.has(piece) && not tmp_match.has(piece):
						tmp_match.append(piece)
				
			index += 1
		return tmp_match
	
	
	func checkAllSide_ForCrash(i,j):
		if i >= width || j >= height:
			return
		var arrBottomMatch = crash_CheckBottom(i,j)
		var arrTopMatch = crash_CheckTop(i,j)
		var arrLeftMatch = crash_CheckLeft(i,j)
		var arrRightMatch = crash_CheckRight(i,j)
		
		return arrTopMatch + arrBottomMatch + arrLeftMatch + arrRightMatch
	
	
	func crash_CheckRight(x,y):
		var arrTop = []
		var newY = y 
		var newX = x + 1
		if newX >= width:
			return arrTop
		
		var rNode = all_pieces[newX][newY]
		if rNode != null:
			if rNode.gemType == GLOBAL.GemTypes.COUNTER:
				if not arr_match_counter_node.has(rNode):
					arr_match_counter_node.append(rNode)
			else:
				if rNode.color == all_pieces[x][y].color:
					arrTop.append(rNode)
		
		return arrTop
	
	
	
	func crash_CheckLeft(x,y):
		var arrTop = []
		var newY = y 
		var newX = x - 1
		if newX <= -1:
			return arrTop
		
		var lNode = all_pieces[newX][newY]
		if lNode != null:
			if lNode.gemType == GLOBAL.GemTypes.COUNTER:
				if not arr_match_counter_node.has(lNode):
					arr_match_counter_node.append(lNode)
			else:
				if lNode.color == all_pieces[x][y].color:
					arrTop.append(lNode)
		
		return arrTop
	
	func crash_CheckTop(x,y):
		var arrTop = []
		var newY = y + 1
		var newX = x
		
		if newY >= height:
			return arrTop
	
		var tNode = all_pieces[newX][newY]
		if tNode != null:
			if tNode.gemType == GLOBAL.GemTypes.COUNTER:
				if not arr_match_counter_node.has(tNode):
					arr_match_counter_node.append(tNode)
			else:
				if tNode.color == all_pieces[x][y].color:
					arrTop.append(tNode)
		
		return arrTop
	
	
	func crash_CheckBottom(x,y):
		var arrTop = []
		if y == 0:
			return arrTop
		var newX = x
		var newY = y - 1
		
		var bNode = all_pieces[newX][newY]
		if bNode != null:
			if bNode.gemType == GLOBAL.GemTypes.COUNTER:
				if not arr_match_counter_node.has(bNode):
					arr_match_counter_node.append(bNode)
			else:
				if bNode.color == all_pieces[x][y].color:
					arrTop.append(bNode)
		
		return arrTop
		pass
	
	
	func reArrange_pieces(arr_row):
		var isFound = false
		for x in arr_row:
			var donwCount = 0
			for y in height:
				if all_pieces[x][y] == null:
					donwCount += 1
				elif all_pieces[x][y].isGrouped == 0:
					if y != 0:
						isFound = true
						var cNode = all_pieces[x][y]
						all_pieces[x][y] = null
						
						var gridVal = Vector2(x,y-donwCount)
						cNode.myPos = gridVal
						all_pieces[gridVal.x][gridVal.y] = cNode
						emit_signal("dropAnime",cNode,grid_to_pixel(gridVal.x,gridVal.y))
				elif all_pieces[x][y].isGrouped != 0:
					donwCount = 0
		
		
		#Check Group Fall
		if check_powerGems().size() != 0:
			var allGroups = []
			var matchIds = []
			for i in width:
				for j in height:
					var xNode = all_pieces[i][j]
					if xNode != null:
						if xNode.matched and xNode.isGrouped != 0:
							if !matchIds.has(xNode.isGrouped) :
								allGroups.append(xNode)
								matchIds.append(xNode.isGrouped)
			if allGroups.size() != 0:
				check_all_groupCanFall(allGroups)
		
		#Timer for animation fall
		if isFound:
			emit_signal("timeAnime")
		else:
			if chainReactionCount > 1 :
				emit_signal("showChain",chainReactionCount)
		
		if isPowerGemOn :
			isPowerGemOn = false
			reArrange_pieces([0,1,2,3,4,5])
		else:
			#print("Final Reaarange Called")
			go_for_DropNewPair()
	
	
	func check_all_groupCanFall(all_group):
		var isFoundGroupOnly = false
		for group in all_group:
			var sPos = group.myPos
			var mSize = group.groupSize
			var dropC = 0
			if sPos.y != 0:
				while(sPos.y != 0):
					sPos.y = sPos.y - 1
					var newSpos = Vector2(sPos.x,sPos.y)
					var endX = sPos.x+mSize.x
					var isBreak = false
					for x in range(newSpos.x,endX):
						if all_pieces[x][newSpos.y] != null:
							isBreak = true
							break
					if not isBreak:
						dropC += 1
					else:
						break
					
				if dropC > 0:
					#move matrix to one column below
					isFoundGroupOnly = true
					var mSpos = Vector2(group.myPos.x,group.myPos.y)
					var mEpos = Vector2(group.myPos.x + group.groupSize.x,group.myPos.y + group.groupSize.y)
					for i in range(mSpos.x,mEpos.x):
						for j in range(mSpos.y,mEpos.y):
							var cNode = all_pieces[i][j]
							all_pieces[i][j] = null
							var newGrid = Vector2(i,j-dropC)
							cNode.myPos = newGrid
							all_pieces[newGrid.x][newGrid.y] = cNode
							emit_signal("dropAnime",cNode,grid_to_pixel(newGrid.x,newGrid.y))
		if isFoundGroupOnly:
			find_matrix()
			crash_find_n_destroy()
			reArrange_pieces([0,1,2,3,4,5])
	
	
	func go_for_DropNewPair():
		emit_signal("_newPair_Emit")
		
	
	
	
	
	
	
	
	
	
	
##################
#################
################
#################
###############
class PairEngine:
	
	signal _Server_Added_Pair
	signal _Request_Add_Pair
	
	var diamondGemCount = 0
	var player1_pairs = []
	var player2_pairs = []
	var crash_droper = 2
	var crash_limiter = 3
	var init_data = []
	var isRequested = false
	var eventNotifier 
	
	func _init():
		spawn_gem_pair()
		pass
		
	func spawn_gem_pair():
		randomize()
		var keys = [];
		for i in GLOBAL.possible_pieces.size():
			for j in GLOBAL.posible_pieces_priority[i]:
				keys.append(i)
		for i in 12:
			diamondGemCount += 1
			randomize()
			var rand1 = floor(rand_range(0,keys.size()))
			var rand2 = floor(rand_range(0,keys.size()))
			var piece1 = GLOBAL.possible_pieces[keys[rand1]];
			var piece2 = GLOBAL.possible_pieces[keys[rand2]];
			
			var json_pair = [keys[rand1],keys[rand2]]
			
			if diamondGemCount % 25 == 0:
				if [true,false][randi() % 2]:
					piece1 = GLOBAL.DiamondGemLoader
					json_pair = [99,keys[rand2]]
				else:
					piece2 = GLOBAL.DiamondGemLoader
					json_pair = [keys[rand1],99]
			
			init_data.append(json_pair)
			player1_pairs.append([piece1,piece2])
			player2_pairs.append([piece1,piece2])
		
		if isRequested:
			isRequested = false
			if eventNotifier != null :
				eventNotifier.send_extraPair()
			else:
				emit_signal("_Server_Added_Pair")
		

	func getNextPair(isP1=false):
		var pairToReturn
		#P1 for Player1
		if isP1:
			pairToReturn = player1_pairs[0]
		else:
			pairToReturn = player2_pairs[0]
		return pairToReturn

	func provide_new_pair(isP1=false):
		var pairToReturn
		#P1 for Player1
		if isP1:
			pairToReturn = player1_pairs[0]
			player1_pairs.remove(0)
		else:
			pairToReturn = player2_pairs[0]
			player2_pairs.remove(0)
		print("Pair array: ",player1_pairs.size())
		if not GLOBAL.isNetworked:
			if player1_pairs.size() < 10 or player2_pairs.size() < 10 :
				spawn_gem_pair()
		elif GLOBAL.isHost:
			if player1_pairs.size() < 10 or player2_pairs.size() < 10 :
				isRequested = true
				init_data = []
				spawn_gem_pair()
		else:
			if player1_pairs.size() < 10 or player2_pairs.size() < 10 :
				print("yes request new pair")
				emit_signal("_Request_Add_Pair")
			
		
		return pairToReturn
	
	func create_array_fromJson(array):
		diamondGemCount = 0
		player1_pairs = []
		player2_pairs = []
		for data in array:
			var p1 = data[0]
			var p2 = data[1]
			var piece1 = getGemFromIndex(p1)
			var piece2 = getGemFromIndex(p2)
			player1_pairs.append([piece1,piece2])
			player2_pairs.append([piece1,piece2])
	
	func add_new_pairRequest():
		if not isRequested:
			#eventNotifier = objeEvent
			isRequested = true
			init_data = []
			spawn_gem_pair()
	
	func append_new_pair(array):
		for data in array:
			var p1 = data[0]
			var p2 = data[1]
			var piece1 = getGemFromIndex(p1)
			var piece2 = getGemFromIndex(p2)
			player1_pairs.append([piece1,piece2])
			player2_pairs.append([piece1,piece2])
	
	
	
	func getGemFromIndex(index):
		if index == 99:
			return GLOBAL.DiamondGemLoader
		else:
			return GLOBAL.possible_pieces[index];
	
	
	func getCounterGem(color,type):
		var cNode
		if type == "n":
			match color:
				"r":
					cNode = preload("res://scenes/pieces/Pink_Piece.tscn")
				"g":
					cNode = preload("res://scenes/pieces/Green_Piece.tscn")
				"y":
					cNode = preload("res://scenes/pieces/Yellow_Piece.tscn")
				"b":
					cNode = preload("res://scenes/pieces/Blue_Piece.tscn")
				_:
					cNode = preload("res://scenes/pieces/Pink_Piece.tscn")
			return cNode
		
		elif type == "c":
			match color:
				"r":
					cNode = preload("res://scenes/pieces/crash_gem/Red_CrashPiece.tscn")
				"g":
					cNode = preload("res://scenes/pieces/crash_gem/Green_CrashPiece.tscn")
				"y":
					cNode = preload("res://scenes/pieces/crash_gem/Yellow_CrashPiece.tscn")
				"b":
					cNode = preload("res://scenes/pieces/crash_gem/Blue_CrashPiece.tscn")
				_:
					cNode = preload("res://scenes/pieces/crash_gem/Red_CrashPiece.tscn")
			return cNode
		elif type == "d":
			return preload("res://scenes/pieces/diamond_gem/Diamond_Piece.tscn")

		
	func fillData_ForNetwork(inArray):
		diamondGemCount = 0
		"""
		player1_pairs = []
		player2_pairs = []
		for data in inArray:
			diamondGemCount += 1
			var p1 = data[0]
			var p2 = data[1]
			
			var piece1 = getCounterGem(p1["c"],p1["t"])
			var piece2 = getCounterGem(p2["c"],p2["t"])
			
			if diamondGemCount % 25 == 0:
				if [true,false][randi() % 2]:
					piece1 = GLOBAL.DiamondGemLoader
				else:
					piece2 = GLOBAL.DiamondGemLoader
			
			player1_pairs.append([piece1,piece2])
			player2_pairs.append([piece1,piece2])
			"""
		pass


###Score Manager 

class ScroreManager :
	func input_NormalGem(counts):
		return counts * 100
	
	func input_powerGem(grid,crashCount):
		return (((grid.x*grid.y)*grid.x) + crashCount) * 100
	
	func inpu_chain(count):
		return count * 1000




