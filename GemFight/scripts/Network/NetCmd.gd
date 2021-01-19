extends Node

# call inside playerButton.
signal conntion_done    
signal conntion_error

var WEBSOCK = preload("res://WebSockConnection.gd")

var webSocket
var targetId 	= ""
var isMatched 	= false
var isPaired 	= false
var isTmpLock	= false
var isWait 		= false
var movedToScene = false
var signalFlag 	= false

var player
var winnerPopup

func _ready():
	webSocket = WEBSOCK.new()
	add_child(webSocket)
	webSocket.parentRef = self

func updateSignal():
	#GLOBAL.pairManager.disconnect("_Request_Add_Pair",self,"request_new_Pair")
	#GLOBAL.pairManager.disconnect("_Server_Added_Pair",self,"send_extraPair")
	if !GLOBAL.pairManager.is_connected("_Request_Add_Pair",self,"request_new_Pair"):
		GLOBAL.pairManager.connect("_Request_Add_Pair",self,"request_new_Pair")
	if !GLOBAL.pairManager.is_connected("_Server_Added_Pair",self,"send_extraPair"):
		GLOBAL.pairManager.connect("_Server_Added_Pair",self,"send_extraPair")
	
func goToConnect():
	targetId = ""
	webSocket.startConnection()

func _disconnect():
	#webSocket.close_connection()
	isMatched = false
	
func sendTestdata():
	#var data = {"user_id": webSocket.uniqueID, "to_user_id": "145","data":"test"}
	#webSocket.sendData_user_to_user(data)
	#print("send test u_to_u : ",data)
	
	#var data = {"user_id": webSocket.uniqueID, "to_user_id": str(targetId),"data":"test"}
	#webSocket.data_sender(data)
	#print("Send disconnect command : ",data)
	pass
	
func connected():
	while(true):
		var t = Timer.new()
		t.set_wait_time(2)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
		t.queue_free()
		var WSconnection = webSocket.socket.get_connection_status() == webSocket.socket.CONNECTION_CONNECTED
		if !WSconnection:
			emit_signal("conntion_error")
			break
		var data = {"match":webSocket.uniqueID}
		sendData(data)
		if isMatched:
			break

func resetConnection():
	var t = Timer.new()
	t.set_wait_time(10)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free()
	if not movedToScene:
		isMatched = false
		isPaired = false
		targetId = ""
		connected()

func connectionFail():
	if is_instance_valid(player):
		player.receive_opponent_lose()

func sendData(inputs):
	webSocket.data_sender(inputs)
	print("\nSend pin")
	pass

func data_received(json):
	if json.has("available_user"):
		var dict =  json["available_user"]
		var id =  dict["id"] 
		if id != null:
			targetId = str(id)
			GLOBAL.isHost = dict["isHost"]
			user_searching_oppponent(false)
			isPaired = true
			emit_signal("conntion_done")
		else:
			print("Not any user available")
			
	elif json.has("u_to_u"):
		#var dict = json["u_to_u"]
		if is_instance_valid(player):
			var dict = json["u_to_u"]
			if dict["to_user_id"] == str(webSocket.uniqueID):
				command_receivedFromServer(dict)
		else:
			var dict = json["u_to_u"]
			if dict.has("goto_home") && is_instance_valid(winnerPopup):
				winnerPopup.replayMessage(dict["goto_home"] != "1")
	pass

func networkDisconnect():
	if is_instance_valid(player):
		player.receive_opponent_lose()

func sendConnectMe(id):
	targetId = id
	isTmpLock = true
	var data = {"conn":str(id),"origin":str(webSocket.uniqueID)}
	sendData(data)

func sendConfirm():
	var data = {"confirm":str(targetId),"origin":str(webSocket.uniqueID)}
	sendData(data)

func user_searching_oppponent(isAvilable:bool):
	webSocket.set_user_available(isAvilable)
	
#Command Client to Host
func sendPairReceieved():
	var dict = {"init_pair_recv":"", "user_id":webSocket.uniqueID, "to_user_id":targetId}
	webSocket.data_sender(dict)
	print("send recv")


#Command Host Send to Client
func send_initialPair(plynm=""):
	var dict = {"init_pair":GLOBAL.pairManager.init_data, "user_id":webSocket.uniqueID, "to_user_id":targetId, "player_name":plynm}
	webSocket.data_sender(dict)

func request_new_Pair():
	var dict = {"new_pair":"", "user_id":webSocket.uniqueID, "to_user_id":targetId}
	webSocket.data_sender(dict)

func send_extraPair():
	var dict = {"extra_pair":GLOBAL.pairManager.init_data, "user_id":webSocket.uniqueID, "to_user_id":targetId}
	webSocket.data_sender(dict)

func send_startGm():
	var time = OS.get_system_time_secs() + 3
	var dict = {"gm_start":time, "user_id":webSocket.uniqueID, "to_user_id":targetId}
	webSocket.data_sender(dict)
	player.startGameAfter(3)

func spwan_new_pairRemoteWindow():
	var dict = {"rmt_spawnPair":"", "user_id":webSocket.uniqueID, "to_user_id":targetId}
	webSocket.data_sender(dict)

func move_pieces(isleft):
	var dict = {"rmt_movePiece":str(int(isleft)), "user_id":webSocket.uniqueID, "to_user_id":targetId}
	webSocket.data_sender(dict)

func rotate_pieces(isclock):
	var dict = {"rmt_rotatePiece":str(int(isclock)), "user_id":webSocket.uniqueID, "to_user_id":targetId}
	webSocket.data_sender(dict)

func drop_pieces(isDrop):
	var dict = {"rmt_dropPiece":str(int(isDrop)), "user_id":webSocket.uniqueID, "to_user_id":targetId}
	webSocket.data_sender(dict)

func sendCounter_GemToplayer(count,health,power):
	var dict = {"send_counter":count,"time":OS.get_system_time_msecs(), "health_p1":health, "power":power, "user_id":webSocket.uniqueID, "to_user_id":targetId}
	webSocket.data_sender(dict)

func sendCounterGem_remotWindow(array):
	var dict = {"rmt_counter":array, "user_id":webSocket.uniqueID, "to_user_id":targetId}
	webSocket.data_sender(dict)

func sendYouWin():
	var dict = {"you_win":"", "user_id":webSocket.uniqueID, "to_user_id":targetId}
	webSocket.data_sender(dict)

func send_lastPairDrop(data):
	var dict = {"lst_drp_par":data, "user_id":webSocket.uniqueID, "to_user_id":targetId}
	webSocket.data_sender(dict)

func send_characterData(data):
	var dict = {"plyr_data":data, "user_id":webSocket.uniqueID, "to_user_id":targetId}
	webSocket.data_sender(dict)
	pass

func send_scoreData(data):
	var dict = {"scorePlayer":data, "user_id":webSocket.uniqueID, "to_user_id":targetId}
	webSocket.data_sender(dict)

func send_healthData(value):
	var dict = {"healthPlayer":value, "user_id":webSocket.uniqueID, "to_user_id":targetId}
	webSocket.data_sender(dict)

func send_supperPower(value):
	var dict = {"supper_power":value, "user_id":webSocket.uniqueID, "to_user_id":targetId}
	webSocket.data_sender(dict)
	
func send_gotoHome(value):
	# value 1 for home, 0 for replay
	var dict = {"goto_home":value, "user_id":webSocket.uniqueID, "to_user_id":targetId}
	webSocket.data_sender(dict)
	
func send_quitGame():
	var dict = {"quit_game":"", "user_id":webSocket.uniqueID, "to_user_id":targetId}
	webSocket.data_sender(dict)

#### Command Received from Server
### Client Side
func command_receivedFromServer(data):
	if data.has("init_pair"):
		var pairArray = data["init_pair"]
		GLOBAL.pairManager.create_array_fromJson(pairArray)
		player.refresh_Pair()
		sendPairReceieved()
	elif data.has("gm_start"):
		player.startGameAfter(2.7)
		#var myTime = OS.get_system_time_secs()
		#var rmtTime = int(data["gm_start"])
		#var diff = rmtTime - myTime
		#if diff < 0:
		#	player.startGameAfter(0)
		#else:
		#	player.startGameAfter(diff)
		#print("Game start, My time : " + str(myTime) + " remote time " + str(rmtTime))
	elif data.has("plyr_data"):
		var arrData = data["plyr_data"]
		player.remote_playerLoad(arrData)
	elif data.has("scorePlayer"):
		player.update_scoreInRemoteWindow(data["scorePlayer"])
	elif data.has("lst_drp_par"):
		var arrData = data["lst_drp_par"]
		player.add_lastPairInRmtWindow(arrData)
	elif data.has("healthPlayer"):
		player.update_healthInRemoteWindow(data["healthPlayer"])
	elif data.has("send_counter"):
		player.receive_counterFrom(int(data["send_counter"]),data["time"],data["health_p1"],data["power"])
	elif data.has("supper_power"):
		player.receive_supperPower(data["supper_power"])
	elif data.has("extra_pair"):
		var arrGem = data["extra_pair"]
		GLOBAL.pairManager.append_new_pair(arrGem)
	elif data.has("new_pair"):
		GLOBAL.pairManager.add_new_pairRequest()
	elif data.has("you_win"):
		player.show_youWin()
	elif data.has("quit_game"):
		player.receive_opponent_lose()
	elif data.has("goto_home"):
		player.receive_stop_opponent_waiting()
	elif data.has("rmt_counter"):
		player.drop_gemInPlayer2Widnow(data["rmt_counter"])
	elif data.has("rmt_spawnPair"):
		player.spawn_pairInPlayer2Window()

	

	

	



#### Command Received from Client
### Server Side
func command_receivedFromClient(data):
    """
	if data.has("init_pair_recv"):
		#send_startGm()
		pass
	elif data.has("rmt_spawnPair"):
		player.spawn_pairInPlayer2Window()
	elif data.has("send_counter"):
		player.receive_counterFrom(int(data["send_counter"]),data["time"])
	elif data.has("rmt_counter"):
		player.drop_gemInPlayer2Widnow(data["rmt_counter"])
	elif data.has("you_win"):
		player.show_youWin()
		player = null
	elif data.has("lst_drp_par"):
		var arrData = data["lst_drp_par"]
		player.add_lastPairInRmtWindow(arrData)
	elif data.has("plyr_data"):
		var arrData = data["plyr_data"]
			player.remote_playerLoad(arrData)
	elif data.has("scorePlayer"):
		player.update_scoreInRemoteWindow(data["scorePlayer"])
	elif data.has("healthPlayer"):
		player.update_healthInRemoteWindow(data["healthPlayer"])
	"""