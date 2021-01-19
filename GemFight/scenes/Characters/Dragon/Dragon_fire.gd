extends Node2D

signal attack_anim_complete
var speed = 180
var isLeft = true
var isGO = false


func _ready():
	$Timer.start()
	pass

func _process(delta):
	if isGO:
		if isLeft:
			self.position.x += speed*delta
		else:
			self.position.x -= speed*delta

func playAnimation():
	$Sprite.flip_h = isLeft
	$AnimationPlayer.play("anim")

func _on_Timer_timeout():
	isGO = false
	emit_signal("attack_anim_complete")
	queue_free()
	pass # Replace with function body.
