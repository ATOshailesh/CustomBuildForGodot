extends Node2D
signal rotate_tap(flag,_position)
signal swiped_down(flag)
signal swiped_left
signal swiped_right
signal swiped(direction)
signal swiped_canceled(start_position)

export(float, 1.0,1.5) var MAX_DIAGONAL_SLOPE = 1.3

onready var timer = $Timer
var swipe_start_position = Vector2()


func _process(delta):
	if isPan :
		_start_pan(get_viewport().get_mouse_position())
		xFactor += delta
	pass

func _input(event):

	if event is InputEventScreenTouch: 
		if event.is_pressed():
			isPan = true
			pos = event.position
		elif not timer.is_stopped():
			_end_detection(event.position)
		
		if not event.is_pressed():
			isPan = false
			if xFactor < 0.12 :#&& not isrealDrag:
				if not islock:
					islock = true
					if event.position.y > 200:
						emit_signal("rotate_tap",true,pos)
#					if event.position.x < 80 && event.position.y > 200:
#						emit_signal("rotate_tap",false,pos)
#					elif event.position.x - 80 < event.position.x && event.position.y > 200:
#						emit_signal("rotate_tap",true,pos)
				timer.stop()
			xFactor = 0
			pos = Vector2()
			if isrealDrag:
				emit_signal("swiped_down",false)
				timer.stop()
			
			islock = false
			isrealDrag = false
	elif event is InputEventScreenDrag:
		isrealDrag = true



var islock = false
var pos = Vector2()
var isPan = false
var isvPan
var isrealDrag = false
var xFactor = 0

func _start_pan(position):
	if pos.distance_to(position) > 30:
		var diretion = (position -  pos).normalized()
		var xDef = position.x -  pos.x
		if xDef < 0:
			xDef = xDef * -1
		if xDef < 20:
			_checkVPan(position)
			return
		
		## Check For Horizonatal Swipe
		var dir = Vector2(-sign(diretion.x),0.0)
		if dir.x == 1 :
			emit_signal("swiped_left")
		else:
			emit_signal("swiped_right")
		pos = position

func _checkVPan(position):
	var diretion = (position -  pos).normalized()
	var xDef = position.y -  pos.y
	if xDef < 0:
		xDef = xDef * -1
	if xDef < 20:
		return
	## Check For Verticle Swipe
	var dir = Vector2(0.0,-sign(diretion.y))
	if dir.y != 1:
		emit_signal("swiped_down",true)
	pos = position
	



func _start_detection(position):
	swipe_start_position = position
	timer.start()
	pass

func _end_detection(position):
	timer.stop()
	var diretion = (position -  swipe_start_position).normalized()
	if abs(diretion.x) + abs(diretion.y) > MAX_DIAGONAL_SLOPE:
		return
	
	if abs(diretion.x) > abs(diretion.y):
		var dir = Vector2(-sign(diretion.x),0.0)
		emit_signal("swiped",Vector2(-sign(diretion.x),0.0))
		if dir.x == 1 :
			emit_signal("swiped_left")
		else:
			emit_signal("swiped_right")
		
	else:
		emit_signal("swiped",Vector2(0.0,-sign(diretion.y)))

func _on_Timer_timeout():
	emit_signal("swiped_canceled",swipe_start_position)
	pass # replace with function body
