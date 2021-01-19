extends Control

signal finish_introduction
signal skip_introduction

func _ready():
	$lblGoal.hide()
	$lblbreakGem.hide()
	$Control.hide()
	self.set_as_toplevel(true)
	pass # Replace with function body.

func startAnimation():
	show()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "lblGoal_anim":
		$AnimationPlayer.play("lblBreakGem_anim")
	elif anim_name == "lblBreakGem_anim":
		$AnimationPlayer.play("basicGem_anim")
	pass # Replace with function body.


func _on_btnStart_pressed():
	emit_signal("finish_introduction")
	queue_free()
	pass # Replace with function body.


func _on_btnSkip_pressed():
	emit_signal("skip_introduction")
	queue_free()
	pass # Replace with function body.
