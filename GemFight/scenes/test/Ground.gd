extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	#$dragon/character.flip_h = true
	#flip_character()
	#call_falldown()
	setupPlayerCharacter()
	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed("ui_down"):
		$player1.call_fall_down()
		$player2.call_fall_down()
	elif event.is_action_pressed("ui_up"):
		$player1.attack()
		$player2.attack()
	elif event.is_action_pressed("ui_left"):
		print("Left")
		$player1.call_fall_down2()
	elif event.is_action_pressed("ui_right"):
		print("Right")
		$player1.call_idle()
		$player2.call_idle()


	
	
func setupPlayerCharacter():
#	var p1 = preload("res://Xmachine1.tscn").instance()
	##  dragon  golem  xmachine  robomachine  knight sugun swordman ninja
	var p1 = characterLoader("dragon")
	var p2 = characterLoader("swordman")
	$player1.myCharacter = p1
	$player2.myCharacter = p2
	p1.position = $player1/golem1.position
	p2.position = $player2/dragon.position
#	p1.scale = Vector2(0.6,0.6)
#	p2.scale = Vector2(0.6,0.6)
	$player2.add_child(p1)
	$player2.add_child(p2)
	$player1.flip_character()
	$player1.call_idle()
	$player2.call_idle()
	
func characterLoader(inputsStr):
	if inputsStr == "dragon":
		var character = preload("res://dragon1.tscn").instance()
		character.scale = Vector2(0.6,0.6)
		return character
	elif inputsStr == "golem":
		var character = preload("res://golem1.tscn").instance()
		character.scale = Vector2(0.5,0.5)
		return character
	elif inputsStr == "xmachine":
		var character = preload("res://Xmachine1.tscn").instance()
		character.scale = Vector2(0.6,0.6)
		return character
	elif inputsStr == "robomachine":
		var character = preload("res://RoboMachine.tscn").instance()
		character.scale = Vector2(0.55,0.55)
		return character
	elif inputsStr == "knight":
		var character = preload("res://Knight.tscn").instance()
		character.scale = Vector2(0.6,0.6)
		return character
	elif inputsStr == "sugun":
		var character = preload("res://Sugun.tscn").instance()
		character.scale = Vector2(0.6,0.6)
		return character
	elif inputsStr == "swordman":
		var character = preload("res://Swordman.tscn").instance()
		character.scale = Vector2(0.6,0.6)
		return character
	elif inputsStr == "ninja":
		var character = preload("res://Ninja.tscn").instance()
		character.scale = Vector2(0.6,0.6)
		return character
				
func call_falldown():
	var t = Timer.new()
	t.set_wait_time(5)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	$golem1/AnimationPlayer.play("fall_down")
	t.set_wait_time(2)
	t.set_one_shot(true)
	t.start()
	yield(t, "timeout")
	t.queue_free()
	$golem1/AnimationPlayer.play("attack_topside")