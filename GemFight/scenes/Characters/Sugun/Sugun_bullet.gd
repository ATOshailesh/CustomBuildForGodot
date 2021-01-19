extends Node2D

signal attack_anim_complete
var speed = 200
var isLeft = true
var isGO = false

func _ready():
	pass

func _process(delta):
	if isGO:
		if isLeft:
			self.position.x += speed*delta
		else:
			self.position.x -= speed*delta

func flipAim():
	$Sprite.flip_h = false
	$Sprite/ParticlesFire.position.x = 95
	$Sprite/ParticlesFire.rotation_degrees = 0

func _on_Timer_timeout():
	queue_free()
	pass # Replace with function body.
	
func fire_explosion():
	isGO = false
	emit_signal("attack_anim_complete")
	$Particles2D.emitting = true
	$Particles2D/Particles2D.emitting = true
	$Particles2D/Particles2D2.emitting = true

