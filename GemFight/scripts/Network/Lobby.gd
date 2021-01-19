extends Node

func _ready():
	get_tree().connect("network_peer_connected",self,"_player_connected")
	$TextEdit.text = "127.0.0.1"
	
	
func _player_connected(id):
	print("player connected to server")
	GLOBAL.isNetworked = true
	GLOBAL.otherPlayerId = id
	get_tree().change_scene("res://scenes/TwoPlayer/TwoPlayerMobile.tscn")
	#hide()
	
func _on_buttonHost_pressed():
	GLOBAL.isHost = true
	GLOBAL.socketMrg = NetworkedMultiplayerENet.new()
	var res = GLOBAL.socketMrg.create_server(4242, 2)
	if res != OK:
		print("Error creating server")
		return
	
	$hostGame.hide()
	$hostGame.disabled = true
	get_tree().set_network_peer(GLOBAL.socketMrg)
	pass # Replace with function body.


func _on_joinGame_pressed():
	print("Joint network")
	GLOBAL.isHost = false
	var ipStr = ""
	if $TextEdit.text != "":
		ipStr = $TextEdit.text
	GLOBAL.socketMrg = NetworkedMultiplayerENet.new()
	GLOBAL.socketMrg.create_client(ipStr,4242)
	get_tree().set_network_peer(GLOBAL.socketMrg)

