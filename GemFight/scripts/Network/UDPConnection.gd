extends Node

var PORT_CLIENT = 1509
var PORT_SERVER = 1507
var IP_SERVER = "127.0.0.1"
var socketUDP = PacketPeerUDP.new()


var isStartProcess = false
var connected = false
var cmdCenter


func _ready():
	print("UDP Created :")
	pass

func startUDP():
	if GLOBAL.isHost:
		start_server()
	else:
		start_client()

func start_server():
	if (socketUDP.listen(PORT_SERVER) != OK):
		printt("Error listening on port: " + str(PORT_SERVER))
	else:
		printt("Listening on port: " + str(PORT_SERVER))
		isStartProcess = true

func start_client():
	if (socketUDP.listen(PORT_CLIENT, IP_SERVER) != OK):
		printt("Error listening on port: " + str(PORT_CLIENT) + " in server: " + IP_SERVER)
	else:
		printt("Listening on port: " + str(PORT_CLIENT) + " in server: " + IP_SERVER)
		isStartProcess = true
		#sendInitPacket()

func sendInitPacket():
	socketUDP.set_dest_address(IP_SERVER,PORT_SERVER)
	var t = Timer.new()
	t.set_wait_time(0.5)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free()
	send_data({"ping":{"":""}})


func _process(delta):
	if isStartProcess:
		if socketUDP.get_available_packet_count() > 0:
			if GLOBAL.isHost:
				var array_bytes = socketUDP.get_packet()
				get_data_from_Client(array_bytes)
			else:
				var array_bytes = socketUDP.get_packet()
				get_data_from_Server(array_bytes)


func get_data_from_Client(data):
	var jData = data.get_string_from_ascii()
	var jsonData = JSON.parse(jData).result
	print(jsonData)
	if jsonData.has("ping"):
		var ip = socketUDP.get_packet_ip()
		var port = socketUDP.get_packet_port()
		socketUDP.set_dest_address(ip,port)
		send_data({"ping":{"":""}})
		connected = true
	else:
		cmdCenter.command_receivedFromClient(jsonData)
	pass

func send_data(data):
	var stg = to_json(data)
	var pac = stg.to_ascii()
	socketUDP.put_packet(pac)
	

func get_data_from_Server(data):
	var jData = data.get_string_from_ascii()
	var jsonData = JSON.parse(jData).result
	print(jsonData)
	if jsonData.has("ping"):
		connected = true
	else:
		cmdCenter.command_receivedFromServer(jsonData)


