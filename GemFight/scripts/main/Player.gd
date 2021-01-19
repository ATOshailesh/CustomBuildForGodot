extends Control

var isPlayer1 = true
var idelPosition
var targetPlayer

var myCharacter


func _ready():
	#idelPosition = $AnimatedSprite.position
	if self.name == "Player1":
		isPlayer1 = true
	else:
		isPlayer1 = false

func refreshUI():
	if isPlayer1:
		if myCharacter != null:
			#myCharacter.get_node("Sprite").flip_h = true
			if myCharacter.get_node("character").scale == Vector2(-1,1):
				myCharacter.get_node("character").scale = Vector2(1,1)
			else:
				myCharacter.get_node("character").scale = Vector2(-1,1)
		

func _on_AnimatedSprite_animation_finished():
	#if $AnimatedSprite.animation != "Idle":
		#print("animation %s finished " % $AnimatedSprite.animation)
	#	call_idle()
		#call_hit()
	pass # Replace with function body.



func runPlayer():
	#$AnimatedSprite.position = $Position2D.position
	#$AnimatedSprite.play("Walk")
	pass
# Animation

func call_hit():
	#$AnimatedSprite.play("attack")
	pass

# Hit to Player 
func call_idle():
#	$AnimatedSprite.play("Idle")
#	$AnimatedSprite.position = idelPosition
	pass
	
func hitLp():
#	$AnimatedSprite.play("Lp")
#	if isPlayer1:
#		$StrongPunch.play()
	pass
	
func hitPunch():
#	$AnimatedSprite.play("Strong")
	pass

func hitLag():
#	$AnimatedSprite.play("Axe")
	pass
	
func hitA1():
#	$AnimatedSprite.play("A1")
	pass
	
# Defend of Player
func defendPunch(count):
#	$AnimatedSprite.z_index = 10
	print("defendPunch")
	if count == 2:
		#$AnimatedSprite.play("GuardBreak")
		#$DragonCharacter._call_hit()
		pass
	else:
		pass
		#$AnimatedSprite.play("DefendKo")
		#$DragonCharacter._call_hit()
	

func attack(target,count):
	#$DragonCharacter._call_attack()
	targetPlayer = target
	myCharacter._call_attack()
	#target._call_hit()
#	return
#	$AnimatedSprite.z_index = 11
#	runPlayer()
#	if count == 2:
#		hitLp()
#	elif count < 4:
#		hitLag()
#
#	elif count < 6:
#		hitA1()
#	else:
#		hitPunch()
#	target.defendPunch(count)

func hitSupperPower(target):
	print("call Super Power.")
	targetPlayer = target
	myCharacter._call_attack()
	#$AnimatedSprite.play("Hadored")


func _hit_anime_complete():
	targetPlayer._call_fall_down()
