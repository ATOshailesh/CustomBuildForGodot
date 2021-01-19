#extends Control
extends CanvasLayer

signal finish_counter_introduction

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_AnimationPlayer_animation_finished(anim_name):
	emit_signal("finish_counter_introduction")
	queue_free()
	pass # Replace with function body.
