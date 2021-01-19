extends Node2D

signal attack_anim_complete

var speed = 190
var isLeft = true
var isGO = false

func startAnime():
	if isLeft:
		$AnimationPlayer.play("stone_anim")
	else:
		$AnimationPlayer.play("stone_rev_anim")
		
func flipAim():
	$Sprite.flip_h = true
	
func _on_Timer_timeout():
	emit_signal("attack_anim_complete")
	queue_free()
	pass # Replace with function body.

func _process(delta):
	if isGO:
		if isLeft:
			self.position.x += speed*delta
		else:
			self.position.x -= speed*delta
		

func _on_AnimationPlayer_animation_finished(anim_name):
	_on_Timer_timeout()
	pass # Replace with function body.
