extends PopupPanel

signal close_popup
signal mode_set

var colorDefault = Color("ffffff")
var colorPressed = Color("f7ec38")

func _ready():
	if GLOBAL.isShowInstruction:
		$TextureRect/btnNormal.disabled = true
		$TextureRect/btnhard.disabled = true
	pass # Replace with function body.

func show():
	.show()
	$TextureRect/AnimationPlayer.play("popup")

func _on_btnClose_pressed():
	$ClickSound.play()
	emit_signal("close_popup")

func _on_btnRight_pressed():
	$ClickSound.play()

func _on_btnEasy_pressed():
	$ClickSound.play()
	GLOBAL.selected_mode = GLOBAL.GameMode.EASY
	emit_signal("mode_set")
	#_on_btnClose_pressed()
	pass # Replace with function body.


func _on_btnNormal_pressed():
	$ClickSound.play()
	GLOBAL.selected_mode = GLOBAL.GameMode.NORMAL
	#_on_btnClose_pressed()
	emit_signal("mode_set")
	pass # Replace with function body.

func _on_btnhard_pressed():
	$ClickSound.play()
	GLOBAL.selected_mode = GLOBAL.GameMode.HARD
	#_on_btnClose_pressed()
	emit_signal("mode_set")
	pass # Replace with function body.

func _on_btnEasy_button_down():
	$TextureRect/btnEasy.modulate = colorPressed
	pass # Replace with function body.


func _on_btnEasy_button_up():
	$TextureRect/btnEasy.modulate = colorDefault
	pass # Replace with function body.


func _on_btnNormal_button_down():
	$TextureRect/btnNormal.modulate = colorPressed
	pass # Replace with function body.


func _on_btnNormal_button_up():
	$TextureRect/btnNormal.modulate = colorDefault
	pass # Replace with function body.


func _on_btnhard_button_down():
	$TextureRect/btnhard.modulate = colorPressed
	pass # Replace with function body.


func _on_btnhard_button_up():
	$TextureRect/btnhard.modulate = colorDefault
	pass # Replace with function body.


func _on_btnClose_button_down():
	$TextureRect/btnClose.modulate = colorPressed
	pass # Replace with function body.


func _on_btnClose_button_up():
	$TextureRect/btnClose.modulate = colorDefault
	pass # Replace with function body.


func _on_btnRight_button_down():
	$TextureRect/btnRight.modulate = colorPressed
	pass # Replace with function body.


func _on_btnRight_button_up():
	$TextureRect/btnRight.modulate = colorDefault
	pass # Replace with function body.
