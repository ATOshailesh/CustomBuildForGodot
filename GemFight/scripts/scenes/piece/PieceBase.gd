extends Node2D

export (String) var color;

# Define type: Normal,Counter, Crash or Diamond
var gemType = GLOBAL.GemTypes.NORMAL

var matched = false
var isGrouped = 0
var myPos = Vector2(0,0)
var groupSize = Vector2(0,0)
var counts = 5

func _ready():
	
	pass

func animColor(vcolor):
#	var sprite = get_node("Sprite")
#	match color:
#		"blue":
#			sprite.modulate = Color("#0911d8")
#		"pink":
#			sprite.modulate = Color("#d20320")
#		"yellow":
#			sprite.modulate = Color("#e8cf07")
#		"green":
#			sprite.modulate = Color("#0de115")
	pass
	

func grayScale():
	var sprite = get_node("Sprite")
	sprite.modulate = Color("#6b6060")
	

func removeFromParent():
	queue_free()

