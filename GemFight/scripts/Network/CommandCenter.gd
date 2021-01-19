extends Node

var TCP = preload("res://scripts/Network/UDPConnection.gd")
var player
var tcpReference

func _init():
	tcpReference = TCP.new()
	add_child(tcpReference)
	tcpReference.cmdCenter = self

func updateSignal():
	GLOBAL.pairManager.connect("_Request_Add_Pair",self,"request_new_Pair")
	GLOBAL.pairManager.connect("_Server_Added_Pair",self,"send_extraPair")

func check_connection():
	tcpReference.sendInitPacket()

#Server Send to Client
func send_initialPair():
	var dict = {"init_pair":GLOBAL.pairManager.init_data}
	tcpReference.send_data(dict)
	
func send_extraPair():
	var dict = {"extra_pair":GLOBAL.pairManager.init_data}
	tcpReference.send_data(dict)

#Clietn Request to Server
func request_new_Pair():
	var dict = {"new_pair":""}
	tcpReference.send_data(dict)
	pass

func sendCounterGem_remotWindow(array):
	var dict = {"rmt_counter":array}
	tcpReference.send_data(dict)
	pass

func spwan_new_pairRemoteWindow():
	var dict = {"rmt_spawnPair":""}
	tcpReference.send_data(dict)

func sendCounter_GemToplayer(count):
	var dict = {"send_counter":count}
	tcpReference.send_data(dict)

func sendYouWin():
	var dict = {"you_win":""}
	tcpReference.send_data(dict)

#### Command Received from Server
### Client Side
func command_receivedFromServer(data):
	if data.has("init_pair"):
		var arrGem = data["init_pair"]
		GLOBAL.pairManager.create_array_fromJson(arrGem)
		player.refresh_Pair()
	elif data.has("extra_pair"):
		var arrGem = data["extra_pair"]
		GLOBAL.pairManager.append_new_pair(arrGem)
	elif data.has("rmt_counter"):
		var array = data["rmt_counter"]
		player.drop_gemInPlayer2Widnow(array)
	elif data.has("rmt_spawnPair"):
		player.spawn_pairInPlayer2Window()
	elif data.has("send_counter"):
		var count = data["send_counter"]
		player.receive_counterFrom(count)
	elif data.has("you_win"):
		player.show_youWin()


#### Command Received from Client
### Server Side
func command_receivedFromClient(data):
	if data.has("new_pair"):
		GLOBAL.pairManager.add_new_pairRequest(self)
	elif data.has("rmt_counter"):
		var array = data["rmt_counter"]
		player.drop_gemInPlayer2Widnow(array)
	elif data.has("rmt_spawnPair"):
		player.spawn_pairInPlayer2Window()
	elif data.has("send_counter"):
		var count = data["send_counter"]
		player.receive_counterFrom(count)
	elif data.has("you_win"):
		player.show_youWin()
