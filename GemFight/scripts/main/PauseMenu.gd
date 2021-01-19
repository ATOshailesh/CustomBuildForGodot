extends Control

var colorSelected = Color("edf25e")

var parentRef



func _ready():
	if GLOBAL.isNetworked:
		$TextureRect.hide()
		$Confirm.show()


func _on_resume_pressed():
	if parentRef != null:
		parentRef.resumeGameNow()
	queue_free()
	pass # Replace with function body.


func _on_resume_button_up():
	$TextureRect/resume.modulate = Color("ffffff")
	pass # Replace with function body.


func _on_resume_button_down():
	$TextureRect/resume.modulate = colorSelected
	pass # Replace with function body.


func _on_restart_pressed():
	GLOBAL.player1Score = 0
	GLOBAL.P1_Win_Count = 0
	GLOBAL.AI_Play_Index = []
	GLOBAL.pairManager = null
	get_tree().change_scene("res://scenes/TwoPlayer/Home.tscn")
	pass # Replace with function body.


func _on_restart_button_up():
	$TextureRect/restart.modulate = Color("ffffff")
	pass # Replace with function body.


func _on_restart_button_down():
	$TextureRect/restart.modulate = colorSelected
	pass # Replace with function body.


func _on_Exit_pressed():
	GLOBAL.player1Score = 0
	GLOBAL.P1_Win_Count = 0
	GLOBAL.AI_Play_Index = []
	GLOBAL.pairManager = null
	get_tree().change_scene("res://scenes/MainMenu/LevelMockup.tscn")
	pass # Replace with function body.


func _on_Exit_button_up():
	$TextureRect/Exit.modulate = Color("ffffff")
	pass # Replace with function body.


func _on_Exit_button_down():
	$TextureRect/Exit.modulate = colorSelected
	pass # Replace with function body.


func _on_tick_pressed():
	GLOBAL.player1Score = 0
	GLOBAL.P1_Win_Count = 0
	GLOBAL.AI_Play_Index = []
	GLOBAL.pairManager = null
	NetCmd.send_quitGame()
	NetCmd._disconnect()
	get_tree().change_scene("res://scenes/MainMenu/LevelMockup.tscn")
	pass # Replace with function body.


func _on_tick_button_up():
	$Confirm/tick.modulate = Color("ffffff")
	pass # Replace with function body.


func _on_tick_button_down():
	$Confirm/tick.modulate = colorSelected
	pass # Replace with function body.


func _on_close_pressed():
	if parentRef != null:
		parentRef.Player1Grid.show() 
	queue_free()
	pass # Replace with function body.


func _on_close_button_up():
	
	$Confirm/close.modulate = Color("ffffff")
	pass # Replace with function body.


func _on_close_button_down():
	$Confirm/close.modulate = colorSelected
	pass # Replace with function body.
