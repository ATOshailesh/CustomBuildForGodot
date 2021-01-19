extends Node

var socket
var isConnected = false
var startPool = false 
var uniqueID = ""
var UUID = preload("res://uuid.gd")

var parentRef
var error

func _ready():
	if OS.get_name() == "iOS" || OS.get_name() == "Android":
		uniqueID = str(UUID.uuidbin()[0])
	else:
		uniqueID = "15"
	print("v4 ",UUID.v4()) #a36aaf27e339
	#uniqueID = UUID.v4()
	print("Unique ID : ",uniqueID)

	pass

func startConnection():
	print("Start connecttion, isConnected : ",isConnected)
	if isConnected:
		print("Socket satus : ",socket.get_connection_status())
		set_user_available(true)
		return 
	socket = WebSocketClient.new()
	socket.verify_ssl = false
	socket.connect("connection_established",self,"_webSocket_Connected")
	socket.connect("connection_error",self,"_webSocket_ConnectionError")
	socket.connect("connection_closed",self,"_webSocket_ConnectionClosed")
	socket.connect("data_received",self,"_webSocket_datareceieved")
	socket.connect("peer_disconnected",self,"_webSocket_disconnected")
	error = socket.connect_to_url(GLOBAL.WEBSOCKET_URL)
	print("Error :: ",error)
	if error != OK:
        print("Unable to connect")
        set_process(false)
	else:
		startPool = true
	#Is project optimize done?

func _process(delta):
	if startPool:
		if socket.get_connection_status() == WebSocketClient.CONNECTION_CONNECTING || socket.get_connection_status() == WebSocketClient.CONNECTION_CONNECTED:
			socket.poll() 

func _webSocket_Connected(protocol):
	print("ws Connected : ",protocol)
	isConnected = true
	#Start Ping when connect
	sendInitCommand()

func _webSocket_disconnected():
	print("_webSocket_disconnected")
	isConnected = false
	startPool = false
	set_process(false)

func _webSocket_ConnectionError():
	print("ws Connection Error.")
	isConnected = false
	startPool = false

func _webSocket_ConnectionClosed(was_clean_close):
	print("_webSocket_ConnectionClosed")
	socket.disconnect_from_host()
	isConnected = false
	startPool = false
	#print("ref: ",parentRef)
	#if parentRef != null:
#		parentRef.networkDisconnect()
	

func _webSocket_datareceieved():
	#print("_webSocket_datareceieved")
	var packet = socket.get_peer(1).get_packet()
	var sss = packet.get_string_from_utf8()
	var jsonData = parse_json(sss)
	print("\nReceived : ",jsonData) 
	if parentRef != null:
		parentRef.data_received(jsonData)

func encode_data(data):
	return str(data).to_utf8() 
	
func sendInitCommand():
	var jsonData = to_json({"set_g_user":{"user_id":uniqueID}})
	socket.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
	socket.get_peer(1).put_packet(encode_data(jsonData))
	set_user_available(true)
	#parentRef.connected()

func set_user_available(isAvailable: bool):
	if isConnected:
		#{u_is_availbale: {user_id: 15, is_available: true}}
		var jsonData = to_json({"u_is_available":{"user_id":str(uniqueID), "is_available": isAvailable}})
		socket.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
		socket.get_peer(1).put_packet(encode_data(jsonData))
		print("\nset user available : ",isAvailable)
		
func data_sender(data):
	sendData_user_to_user(data)
#	if isConnected:
#	var jsonData = to_json({"u_to_all_u":data})
#		socket.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
#		socket.get_peer(1).put_packet(encode_data(jsonData))

func sendData_user_to_user(data):
	if isConnected:
		if !data.has("to_user_id"):
			print("Missing to_user_id : ",data)
			return
		var jsonData = to_json({"u_to_u":data})
		print("Send data : ",jsonData)
		socket.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
		socket.get_peer(1).put_packet(encode_data(jsonData))
	else:
		print("Fail send data, Socket not connected.")
		if parentRef != null:
			parentRef.connectionFail()
		#startConnection()
		
func close_connection():
	if socket != null:
		socket.disconnect_from_host()
