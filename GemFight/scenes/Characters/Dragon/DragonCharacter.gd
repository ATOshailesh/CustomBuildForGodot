extends Node2D

onready var FireBall = preload("res://scenes/Characters/Dragon/Dragon_fire.tscn")
onready var BlastW = preload("res://scenes/anime/BlastW.tscn")

var const_pos = Vector2(0,0)

func _ready():
	$Sprite.play("Idle")
	const_pos = $Sprite.position

func _call_attack():
	$Sprite.play("attack")

func _call_hit():
	$Sprite.play("hit")

func _on_Sprite_animation_finished():
	var isPlayAnim = true
	if $Sprite.animation == "hit":
		isPlayAnim = false
		_call_idle()
		pass
	elif $Sprite.animation == "attack":
		
		pass
	
	if isPlayAnim:
		$Sprite.play("Idle")
	

func _call_idle():
	
	var animeSmoke = BlastW.instance()
	self.get_parent().add_child(animeSmoke)
	animeSmoke.position = self.position
	animeSmoke.position.y += 20
	
	var t = Timer.new()
	t.set_wait_time(1)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free()
	play_idle()


func play_idle():
	
	$Sprite.position.y -= 20
	$Sprite.play("Idle")
	$Sprite.position = const_pos

func _on_Sprite_frame_changed():
	if $Sprite.animation == "attack":
		if $Sprite.frame == 2:
			$attack.play()
		elif $Sprite.frame == 3:
			print("Fire ")
			var fireball = FireBall.instance()
			fireball.connect("attack_anim_complete",self.get_parent(),"_hit_anime_complete")
			fireball.position = self.position
			fireball.position.y -= 10
			if $Sprite.flip_h:
				fireball.position.x += 15
				fireball.isLeft = true
			else:
				fireball.isLeft = false
				fireball.position.x -= 15
			fireball.isGO = true
			fireball.playAnimation()
			self.get_parent().add_child(fireball)
			
	elif $Sprite.animation == "hit":
		if $Sprite.frame == 3:
			$Sprite.position.y += 20
			
	
	pass # Replace with function body.
