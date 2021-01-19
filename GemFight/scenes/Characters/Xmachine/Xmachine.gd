extends "res://scenes/Characters/Dragon/DragonCharacter.gd"

onready var FireBullet = preload("res://scenes/Characters/Xmachine/XBullet.tscn")

func _ready():
	pass

func _call_attack():
	if $Sprite.flip_h:
		$Sprite/muzzle.flip_h = true
		$Sprite/muzzle.position = Vector2(60.354,-58.541)
	$AnimationPlayer.play("fire")
	$Sprite.play("attack")
	
	$attack.play()
	var fireball = FireBullet.instance()
	self.get_parent().add_child(fireball)
	fireball.connect("attack_anim_complete",self.get_parent(),"_hit_anime_complete")
	fireball.position = self.position
	fireball.position.y -= 15
	
	
	if $Sprite.flip_h:
		fireball.isLeft = true
		fireball.position.x += 50
	else:
		fireball.isLeft = false
		fireball.position.x -= 50
	fireball.isGO = true
	

func _on_Sprite_animation_finished():
	._on_Sprite_animation_finished()
	
	pass # Replace with function body.

func play_idle():
	
	$Sprite.position.y -= 20
	$Sprite.play("Idle")
	$Sprite.position = const_pos

func _on_Sprite_frame_changed():
	if $Sprite.animation == "attack":
		if $Sprite.frame == 2:
			pass
			
	elif $Sprite.animation == "hit":
		if $Sprite.frame == 3:
			$Sprite.position.y += 20
			pass


func _on_AnimationPlayer_animation_finished(anim_name):
	$AnimationPlayer.play("init")
	pass # Replace with function body.
