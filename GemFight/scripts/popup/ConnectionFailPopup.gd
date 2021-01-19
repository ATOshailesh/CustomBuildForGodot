extends Control

signal retry
signal close

var targetPos

func _ready():
#	$Tween3.interpolate_property($Container,"rect_position",oldPOs,Vector2(10,oldPOs.y),0.3,Tween.TRANS_LINEAR,Tween.EASE_IN,0.5)
#	$Tween3.start()
	targetPos = $popup.rect_position
	print("pos ",targetPos)
	$Tween.interpolate_property($popup,"rect_position",Vector2(targetPos.x,900),targetPos,0.5,Tween.TRANS_LINEAR,Tween.EASE_IN,0.1)
	$Tween.start()
	pass # Replace with function body.


func _on_btnRetry_pressed():
	$ClickSound.play()
	$popup.hide()
	emit_signal("retry")
	queue_free()
	pass # Replace with function body.


func _on_btnClose_pressed():
	$ClickSound.play()
	emit_signal("close")
	queue_free()
	pass # Replace with function body.


func _on_Tween_tween_completed(object, key):
	pass # Replace with function body.

func _on_Tween_tween_started(object, key):
	$popup.show()
	pass # Replace with function body.
