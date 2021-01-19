extends Node2D

onready var Player1Grid = $Player1Grid
onready var Player2Grid = $Player2Grid

var PORT_CLIENT = 1509
var PORT_SERVER = 1507
var IP_SERVER = "127.0.0.1"


func _ready():
	$BgPlayer.play()
	Player2Grid.isMainGrid = 1
	Player2Grid.isMainGrid = 0
	
	counterPatternGenret()
	if GLOBAL.isNetworked:
		Player2Grid.get_node("lblScore").hide()
		_configure_TwoPlayers()
		if NetCmd.isPaired:
			NetCmd.player = self
			if GLOBAL.isHost:
				print("Host Of Net")
				sendInitPair()
		else:
			if not cmdManager.tcpReference.connected :
				cmdManager.tcpReference.startUDP()
			cmdManager.player = self
			if not GLOBAL.isFromGame:
				if GLOBAL.isHost:
					check_client_connection()
				else:
					sendPingToserver()
				pass
			else:
				if GLOBAL.isHost :
					cmdManager.tcpReference.connected = false
					check_client_connection()
				else:
					sendPingToserver()
	
	$SwipeDetector.z_index = 10
	
	pass

var isStartGame = false
func sendInitPair():
	#while(true):
	var t = Timer.new()
	t.set_wait_time(0.5)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free()
#	if isStartGame:
#		isStartGame = false
#		break
	NetCmd.send_initialPair()
	NetCmd.updateSignal()
	$SwipeDetector.z_index = 10


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
	$SwipeDetector.z_index = 10
	


func sendPingToserver():
	var t = Timer.new()
	t.set_wait_time(0.5)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free()
	cmdManager.check_connection()
	print("Send...")


func check_client_connection():
	while(true):
		var t = Timer.new()
		t.set_wait_time(0.5)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
		t.queue_free()
		if cmdManager.tcpReference.connected:
			cmdManager.send_initialPair()
			print("LLL")
			break


func refresh_Pair():
	Player1Grid.showNextPair()
	Player2Grid.showNextPair()


func counterPatternGenret():
	GLOBAL.counter_pieces = []
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



func _on_Player1Grid_GameOver():
	if GLOBAL.isNetworked:
		print("This player's game over ")
		cmdManager.sendYouWin()
		NetCmd.sendYouWin()
		Player2Grid.gmState = GLOBAL.GameState.NONE
		Player1Grid.gmState = GLOBAL.GameState.NONE
	else:
		_pass_GameoverToUser(Player2Grid)
	pass # replace with function body


func _on_Player2Grid_GameOver():
	_pass_GameoverToUser(Player1Grid)


func _pass_GameoverToUser(targetObj):
	targetObj.showYouWin()
	pass

func received_counterGem_remote(counts):
	Player1Grid._received_CounterGem(counts)
	pass


#Player1 send to Player2
func _on_Player1Grid_SendCounterGem(counts):
	if GLOBAL.isNetworked:
		Player1Grid.my_dropTime = OS.get_system_time_msecs()
		cmdManager.sendCounter_GemToplayer(counts)
		NetCmd.sendCounter_GemToplayer(counts,0)
	else:
		Player2Grid._received_CounterGem(counts)
	pass # replace with function body

#Player2 send to Player1
func _on_Player2Grid_SendCounterGem(counts):
	if not GLOBAL.isNetworked:
		Player1Grid._received_CounterGem(counts)
	pass # replace with function body


func _on_WaitTimer_timeout():
	if Player1Grid.gmState == GLOBAL.GameState.RUNNING && Player2Grid.gmState == GLOBAL.GameState.RUNNING:
		Player1Grid.DROP_DEFAULT_SPEED += 100 
		Player2Grid.DROP_DEFAULT_SPEED += 100 
	pass # replace with function body


func _configure_TwoPlayers():
	if GLOBAL.isHost:
		Player1Grid.set_name("player_grid1")
		Player1Grid.set_network_master(get_tree().get_network_unique_id())
		
		Player2Grid.set_name("player_grid2")
		Player2Grid.set_network_master(GLOBAL.otherPlayerId)
		
		Player1Grid.send_initialData() 
		
		if NetCmd.isPaired:
			Player1Grid.set_network_master(int(NetCmd.webSocket.uniqueID))
			Player2Grid.set_network_master(int(NetCmd.targetId))
		
	else:
		Player1Grid.set_name("player_grid2")
		Player1Grid.set_network_master(get_tree().get_network_unique_id())
		
		Player2Grid.set_name("player_grid1")
		Player2Grid.set_network_master(GLOBAL.otherPlayerId) 
		
		if NetCmd.isPaired:
			Player1Grid.set_network_master(int(NetCmd.webSocket.uniqueID))
			Player2Grid.set_network_master(int(NetCmd.targetId))

func send_counter_gemToRemoteWindow(array):
	#cmdManager.sendCounterGem_remotWindow(array)
	NetCmd.sendCounterGem_remotWindow(array)
	pass

func drop_gemInPlayer2Widnow(array):
	Player2Grid.drop_counterGemIn_remoteWindow(array)

func send_cmd_spawnPair():
	#cmdManager.spwan_new_pairRemoteWindow()
	pass

func spawn_pairInPlayer2Window():
	Player2Grid.spaw_pair_from_top()

func receive_counterFrom(counts,time):
	Player1Grid.c_dropTime = time
	Player1Grid._received_CounterGem(int(counts))

func show_youWin():
	Player1Grid.showYouWin()
	Player2Grid.gmState = GLOBAL.GameState.NONE
	Player1Grid.gmState = GLOBAL.GameState.NONE

func _on_SwipeDetector_swiped_left():
	Player1Grid.move_piece_left_right(true)

func _on_SwipeDetector_swiped_right():
	Player1Grid.move_piece_left_right(false)

func _on_SwipeDetector_swiped_down(flag):
	Player1Grid.isDropedIn = flag

func _on_SwipeDetector_rotate_tap(flag,_position):
	
	if not Player1Grid.onTouchRotation(_position):
		if _position.x < 80:
			Player1Grid.rotate_piece_(false)
		elif get_viewport().get_visible_rect().size.x - 80 < _position.x:
			Player1Grid.rotate_piece_(true)

func move_piece_RemoteWindow(flag):
	Player2Grid.move_piece_left_right(flag)

func rotaote_piece_RemoteWindow(flag):
	Player2Grid.rotate_piece_(flag)

func dropin_piece_RemoteWindow(flag):
	Player2Grid.isDropedIn = flag

func sendLastPairData(data):
	NetCmd.send_lastPairDrop(data)
	$SwipeDetector.z_index = 10
	pass

func add_lastPairInRmtWindow(data):
	Player2Grid.putGemIn(data)
	$SwipeDetector.z_index = 10
	pass