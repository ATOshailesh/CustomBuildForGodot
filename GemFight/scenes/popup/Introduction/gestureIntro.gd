extends Control

signal finish_ges_introduction
signal tap_to_rotate
signal skip_introduction

func _ready():
	pass # Replace with function body.

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "left_right_anim":
		playTapIntroduction()
	elif anim_name == "tap_anim":
		$AnimationPlayer.play("swipe_down_anim")
	elif anim_name == "swipe_down_anim":
		emit_signal("finish_ges_introduction")		
		queue_free()
	pass # Replace with function body.

func playTapIntroduction():
	#get_parent().add_child(self)
	var t = Timer.new()
	t.set_wait_time(1)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free()
	$AnimationPlayer.play("tap_anim")

func call_tap():
	$TapHand/tap_explotion.emitting = true
	
	emit_signal("tap_to_rotate")
	
	

func _on_btnSkip_pressed():
	emit_signal("skip_introduction")
	queue_free()
	pass # Replace with function body.
