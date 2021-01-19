extends Node2D

var stream = [
	preload("res://art/sounds/blast1.wav"),
	#preload("res://art/sounds/alterkartoffelsack__glass-breaking.wav"),
	preload("res://art/sounds/DropGem.wav"),
	preload("res://art/sounds/GroupSound.wav"),
	preload("res://art/sounds/anton__glass-a-pp.wav")
	]



func _ready():
	loadSoundWithID()
	pass # Replace with function body.


func loadSoundWithID(idInd=0):
	$AudioStreamPlayer.stream = stream[idInd]
	$AudioStreamPlayer.pitch_scale = 0.8
	$AudioStreamPlayer.bus = getBus(idInd)
	$AudioStreamPlayer.play()

func getBus(id):
	if id == 0:
		return "BackGround"
	elif id == 1:
		return "Normal"
	elif id == 2:
		return "BackGround"
	elif id == 3:
		return "Normal"

func _on_AudioStreamPlayer_finished():
	queue_free()
	pass # Replace with function body.


func stopPlayer(isRemove=false):
	$AudioStreamPlayer.stop()
	if isRemove:
		queue_free()