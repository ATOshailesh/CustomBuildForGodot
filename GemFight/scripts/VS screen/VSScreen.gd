extends Control

var SCREEN_WIDTH = 0.0
var SCREEN_HEIGHT = 0.0



func _ready():
	SCREEN_WIDTH = get_viewport().get_visible_rect().size.x
	SCREEN_HEIGHT = get_viewport().get_visible_rect().size.y
	$Container.hide()
	if not GLOBAL.isNetworked:
		startAnimation()


func startAnimation():
	var objePattern = preload("res://scripts/PlayerPattern/PlayerPattern.gd").PlayerPattern.new()
	var p1Data = objePattern.getPlayerInfo(GLOBAL.p1Index)
	var p2Data = objePattern.getPlayerInfo(GLOBAL.p2Index)
	$Container/player1/TextureRect.texture = load(p1Data["image_flip"])
	$Container/player2/TextureRect.texture = load(p2Data["image"])
	
	$Container.rect_position.x = - SCREEN_WIDTH - 10
	var oldPOs = $Container.rect_position
	
	$Container.rect_position = oldPOs
	$Container.show()
	
	$Tween3.interpolate_property($Container,"rect_position",oldPOs,Vector2(10,oldPOs.y),0.3,Tween.TRANS_LINEAR,Tween.EASE_IN,0.5)
	$Tween3.start()
	
	$Container/fight.rect_position.x = SCREEN_WIDTH
	$Tween.interpolate_property($Container/fight,"rect_position",Vector2(SCREEN_WIDTH,$Container/fight.rect_position.y),Vector2(0,$Container/fight.rect_position.y),0.4,Tween.TRANS_BOUNCE,Tween.EASE_IN,1.5)
	$Tween.start()
	
	$Tween2.interpolate_property($Container/vs/Sprite,"scale",Vector2(0,0),Vector2(0.3,0.3),0.3,Tween.TRANS_ELASTIC,Tween.EASE_IN,0.5)
	$Tween2.start()






func _on_Tween_tween_completed(object, key):
	
	pass # Replace with function body.
