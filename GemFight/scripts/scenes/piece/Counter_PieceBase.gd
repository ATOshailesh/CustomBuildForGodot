extends "res://scripts/scenes/piece/PieceBase.gd"

signal GemConverted

var isDroped = false
var targetPos = Vector2(0,0)


func _ready():
	gemType = GLOBAL.GemTypes.COUNTER
	$counterText.text = str(counts)
	pass

func changeToNormalGem():
	counts -= 1 
	$AnimationPlayer.play("pop_animation")
	if counts == 0:
		#$AnimationPlayer.play("blink_anime")
		gemType = GLOBAL.GemTypes.NORMAL
		$counterText.text = ""
	else:
		$counterText.text = str(counts)
	


func changeTexture():
	if $counterText.text == "":
		var sprite = get_node("Sprite")
		match color:
			"blue":
				sprite.texture = preload("res://art/gems/Blue Piece.png")
			"pink":
				sprite.texture = preload("res://art/gems/Pink Piece.png")
			"yellow":
				sprite.texture = preload("res://art/gems/Yellow Piece.png")
			"green":
				sprite.texture = preload("res://art/gems/Green Piece.png")
		
		$counterText.text = ""
		$counterText.hide()	
		emit_signal("GemConverted")
		
