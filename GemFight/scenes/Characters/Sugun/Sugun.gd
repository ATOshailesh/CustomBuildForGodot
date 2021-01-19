extends "res://scenes/Characters/Dragon/DragonCharacter.gd"

onready var FireBullet = preload("res://scenes/Characters/Sugun/Sugun_bullet1.tscn")

func _on_Sprite_animation_finished():
	._on_Sprite_animation_finished()
	pass # Replace with function body.


func _on_Sprite_frame_changed():
	if $Sprite.animation == "attack":
		#if $Sprite.frame != 0:
		#self.get_parent()._hit_anime_complete()
		$attack.play()
		var fireball = FireBullet.instance()
		self.get_parent().add_child(fireball)
		fireball.connect("attack_anim_complete",self.get_parent(),"_hit_anime_complete")
		fireball.position = self.position
		fireball.position.y += 15
		
		if $Sprite.flip_h:
			fireball.isLeft = true
			fireball.position.x += 40
		else:
			fireball.isLeft = false
			fireball.position.x -= 30
			fireball.flipAim()
		fireball.isGO = true
			
	elif $Sprite.animation == "hit":
		if $Sprite.frame == 3:
			$Sprite.position.y += 10
			pass
