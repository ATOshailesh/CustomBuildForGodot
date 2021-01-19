extends PopupPanel

signal close_popup

var colorDefault = Color("ffffff")
var colorPressed = Color("f7ec38")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func show():
	.show()
	$TextureRect/AnimationPlayer.play("popup")
	
func setMessage(msg : String):
	if msg != "":
		$TextureRect/message.text = msg
	
func _on_btnClose_pressed():
	$ClickSound.play()
	emit_signal("close_popup")
	hide()

func _on_btnClose_button_down():
	$TextureRect/btnClose.modulate = colorPressed
	pass # Replace with function body.

func _on_btnClose_button_up():
	$TextureRect/btnClose.modulate = colorDefault
	pass # Replace with function body.
