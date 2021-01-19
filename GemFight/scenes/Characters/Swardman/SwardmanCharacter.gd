extends "res://scenes/Characters/Dragon/DragonCharacter.gd"


func _on_Sprite_animation_finished():
	._on_Sprite_animation_finished()
	
	pass # Replace with function body.
	
#func _ready():	
#	if $Sprite.flip_h:
#		$Sprite.position.x += 27
#	else:
#		$Sprite.position.x -= 27

func play_idle():
	$Sprite.position.y -= 20
	$Sprite.play("Idle")
	$Sprite.position = const_pos
	
func _on_Sprite_frame_changed():
	if $Sprite.animation == "attack":
		$attack.play()
		#if $Sprite.frame == 1:
		if $Sprite.frame == 8:
			self.get_parent()._hit_anime_complete()
	elif $Sprite.animation == "hit":
		if $Sprite.frame == 3:
			$Sprite.position.y += 20
			pass
	
	pass # Replace with function body.