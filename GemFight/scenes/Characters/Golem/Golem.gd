extends "res://scenes/Characters/Dragon/DragonCharacter.gd"

onready var FireBullet = preload("res://scenes/Characters/Golem/GolemStone.tscn")


func _on_Sprite_animation_finished():
	._on_Sprite_animation_finished()
	pass # Replace with function body.

func play_idle():
	$Sprite.position.y -= 20
	$Sprite.play("Idle")
	$Sprite.position = const_pos
	

func _on_Sprite_frame_changed():
	if $Sprite.animation == "attack":
		if $Sprite.frame == 7:
			#self.get_parent()._hit_anime_complete()
			$attack.play()
			var fireball = FireBullet.instance()
			self.get_parent().add_child(fireball)
			fireball.connect("attack_anim_complete",self.get_parent(),"_hit_anime_complete")
			fireball.position = self.position
			fireball.position.y -= 20
			
			if $Sprite.flip_h:
				fireball.position.x += 12
				fireball.isLeft = true
				fireball.flipAim()
			else:
				fireball.isLeft = false
				fireball.position.x -= 10
			fireball.startAnime()
			fireball.isGO = true
#	elif $Sprite.animation == "hit":
#		if $Sprite.frame == 6:
#			$Sprite.position.y += 20
#			pass
	pass # Replace with function body.

