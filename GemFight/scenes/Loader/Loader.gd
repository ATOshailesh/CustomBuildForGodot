extends Control

#func _ready():
#	pass
#
#func _process(delta):
#	pass

#func hide():
#	$AnimationPlayer.stop()
#	#.hide()
#	print("Hide")
#	pass

#func show():
#	#.show()
#	$AnimationPlayer.play("round")
#	print("Show")
	
func showLoader():
	$AnimationPlayer.play("round")
	self.show()
	
func hideLoade():
	self.hide()
	var t = Timer.new()
	t.set_wait_time(0.5)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free()
	$AnimationPlayer.stop()
