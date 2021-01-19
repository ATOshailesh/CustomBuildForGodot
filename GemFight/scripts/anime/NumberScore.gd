extends Node2D

func _ready():
	$AnimationPlayer.play("scoreAnimation")
	pass # Replace with function body.

func _on_AnimationPlayer_animation_finished(anim_name):
	print("Completed animation")
	#queue_free()
	pass # Replace with function body.
