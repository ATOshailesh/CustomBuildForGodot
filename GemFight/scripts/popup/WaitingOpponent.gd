extends Control

#signal cancel_waiting_opponent(isBackHome)
signal go_home

var isSearching = false

func _ready():
	pass # Replace with function body.


func show():
	.show()
	isSearching = true
	$AnimationPlayer.play("Title_animate")
	$CanvasLayer/lblNotFoundMsg.hide()
	$Timer.start(10)

func _on_btnCancel_pressed():
	#emit_signal("cancel_waiting_opponent",false)
	#isSearching = false
	#self.hide()
	pass

func _on_AnimationPlayer_animation_finished(anim_name):
	if isSearching:
		$AnimationPlayer.play("Title_animate")
	else:
		$AnimationPlayer.stop()


func _on_Timer_timeout():
	$CanvasLayer/lblNotFoundMsg.show()
	pass # Replace with function body.


func _on_btnHome_pressed():
	#emit_signal("cancel_waiting_opponent",true)
	emit_signal("go_home")
	isSearching = false
	self.hide()
