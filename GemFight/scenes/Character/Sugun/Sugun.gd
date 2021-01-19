extends Node2D

onready var FireBullet = preload("res://scenes/Characters/Sugun/Sugun_bullet1.tscn")
onready var BlastW = preload("res://scenes/anime/BlastW.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func play_idle():
	$AnimationPlayer.play("idle")
	
func _call_attack():
	$AnimationPlayer.play("attack")

func _call_fall_down():
	$AnimationPlayer.play("fall_down")

func _blast_sky():
	var animeSmoke = BlastW.instance()
	self.get_parent().add_child(animeSmoke)
	animeSmoke.position = self.position
	animeSmoke.position.y -= 20
	pass

# Call traget player fall_down animation
func _call_hit():
	self.get_parent()._hit_anime_complete()
	pass


func firing():
	var fireball = FireBullet.instance()
	self.get_parent().add_child(fireball)
	fireball.connect("attack_anim_complete",self.get_parent(),"_hit_anime_complete")
	fireball.position = $character.position
	fireball.position = self.position
	fireball.position.y -= 46
	#if $Sprite.flip_h:
	if $character.scale == Vector2(-1,1):
		fireball.position.x += 45
		fireball.isLeft = true
	else:
		fireball.isLeft = false
		fireball.position.x -= 45
		fireball.flipAim()
	fireball.isGO = true
	pass
	
func _on_AnimationPlayer_animation_finished(anim_name):
	if not anim_name == "idle":
		play_idle()
	pass # Replace with function body.
	