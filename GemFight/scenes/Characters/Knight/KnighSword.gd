extends Node2D

signal attack_anim_complete

var speed = 200
var isLeft = true
var isGO = false

func _ready():
	startAnime()
	pass

func startAnime():
	if isLeft:
		$AnimationPlayer.play("rotate_2")
	else:
		$AnimationPlayer.play("rotate_1")
	$Timer.start()

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