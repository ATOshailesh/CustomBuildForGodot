extends Node2D
signal lbl_anime_done

onready var upTween = get_node("moveup")


func _ready():
	pass
	
func startAnime(targetPos):
	var newPos = targetPos
	newPos.y = newPos.y - 20
	upTween.interpolate_property(self,"position",targetPos,newPos,2.5,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	upTween.start()

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func removeFromParent():
	queue_free()

func _on_moveup_tween_completed(object, key):
	emit_signal("lbl_anime_done")
	queue_free()
	pass # replace with function body
