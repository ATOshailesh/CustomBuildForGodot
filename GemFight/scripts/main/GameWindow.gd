extends Node2D

func _ready():
	counterPatternGenret()
	$Player1Grid.ignoreSignal = false
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


func _on_color_pressed():
	
	if GLOBAL.selectColor == "r":
		GLOBAL.selectColor = "g"
	elif GLOBAL.selectColor == "g":
		GLOBAL.selectColor = "b"
	elif GLOBAL.selectColor == "b":
		GLOBAL.selectColor = "y"
	elif GLOBAL.selectColor == "y":
		GLOBAL.selectColor = "r"
	$Control/color.text = GLOBAL.selectColor
	pass # replace with function body


func _on_crashOn_pressed():
	if GLOBAL.isCrashOn == "n":
		GLOBAL.isCrashOn = "c"
		$Control/crashOn.text = "Crash Gem"
	elif GLOBAL.isCrashOn == "c":
		GLOBAL.isCrashOn = "co"
		$Control/crashOn.text = "Counter Gem"
	elif GLOBAL.isCrashOn == "co":
		GLOBAL.isCrashOn = "n"
		$Control/crashOn.text = "Normal Gem"
	pass # replace with function body


func _on_fire_pressed():
	
	#use first player then use blow code
	$Player1Grid.get_piece_FixPosition()
	
	#if load player2 then use blow code
	#$Player2Grid.get_piece_FixPosition()
	pass # replace with function body


func _on_fire2_pressed():
	if not $Player1Grid.ignoreSignal:
		$Player1Grid.ignoreSignal = true
		$Control/timer.text = "Tmer On"
	else:
		$Player1Grid.ignoreSignal = false
		$Control/timer.text = "Tmer off"
	pass # replace with function body


func _on_WaitTimer_timeout():
	print("Timer Finished")
	pass # replace with function body
