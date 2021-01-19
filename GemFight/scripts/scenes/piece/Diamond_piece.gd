extends "res://scripts/scenes/piece/PieceBase.gd"



func _ready():
	gemType = GLOBAL.GemTypes.DIAMOND
	$Sprite.hide()
	$AnimatedSprite.show()
	$AnimatedSprite.play("rot_dia")
	pass

