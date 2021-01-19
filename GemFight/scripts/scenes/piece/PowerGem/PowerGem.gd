extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func changeTexture(color,sizeScale,offset):
	var txtSize = offset#64.0
	var perScale = 0.44
	var x = (sizeScale.x * txtSize)/perScale 
	var y = (sizeScale.y * txtSize)/perScale + txtSize/4
#	if sizeScale.x == 2 && sizeScale.y == 3 :
#		pass
#	else:
#		self.scale = sizeScale
	$Sprite.scale = Vector2(0.44,0.44)
	position.x = position.x + txtSize/2 + ((sizeScale.x - 2) * txtSize/2)
	position.y = position.y - txtSize/2 - ((sizeScale.y - 2) * txtSize/2) 
	#preload("res://art/powergem/power_b_2x2.png")
	match color:
		"blue":
			var path = "res://art/powergem/blue/power_b_"+str(sizeScale.x)+"x"+str(sizeScale.y)+".png"
			$Sprite.texture = load(path)
				#$Sprite.texture = preload("res://art/extra/blue_power.png")
		"pink":
			var path = "res://art/powergem/red/power_r_"+str(sizeScale.x)+"x"+str(sizeScale.y)+".png"
			$Sprite.texture = load(path)
			#$Sprite.texture = preload("res://art/extra/red_power.png")
		"yellow":
			var path = "res://art/powergem/yellow/power_y_"+str(sizeScale.x)+"x"+str(sizeScale.y)+".png"
			$Sprite.texture = load(path)
			#$Sprite.texture = preload("res://art/extra/yellow_power.png")
		"green":
			var path = "res://art/powergem/green/power_b_"+str(sizeScale.x)+"x"+str(sizeScale.y)+".png"
			$Sprite.texture = load(path)
			#$Sprite.texture = preload("res://art/extra/green_power.png")


func removeGlow():
	$Sprite.material = null
	$Sprite.modulate = Color("#6b6060")

func removeFromParent():
	queue_free()
	
	pass

