extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setTexture(black=true):
	if black:
		$Sprite.texture = preload("res://art/extra/black_place.png")
	else:
		$Sprite.texture = preload("res://art/extra/white_place.png")