extends Control

signal cancel_search_opponent(isBackHome)

var isSearching = false

func _ready():
	pass # Replace with function body.


func show():
	.show()
	isSearching = true
	$AnimationPlayer.play("Title_animate")
	$CanvasLayer/lblNotFoundMsg.hide()
	$Timer.start(20)

func _on_btnCancel_pressed():
	emit_signal("cancel_search_opponent",false)
	isSearching = false
	self.hide()


func _on_AnimationPlayer_animation_finished(anim_name):
	if isSearching:
		$AnimationPlayer.play("Title_animate")
	else:
		$AnimationPlayer.stop()


func _on_Timer_timeout():
	$CanvasLayer/lblNotFoundMsg.show()
	pass # Replace with function body.


func _on_btnHome_pressed():
	emit_signal("cancel_search_opponent",true)
	isSearching = false
	self.hide()
