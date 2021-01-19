#extends Control
extends CanvasLayer

signal finish_power_introduction
signal skip_introduction

func _ready():
	pass # Replace with function body.


func _on_AnimationPlayer_animation_finished(anim_name):
	emit_signal("finish_power_introduction")
	queue_free()
	pass # Replace with function body.


func _on_btnSkip_pressed():
	emit_signal("skip_introduction")
	queue_free()
	pass # Replace with function body.
