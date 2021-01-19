extends Control

signal guset_login_successfully(name)

func _ready():
	pass

func setName(name):
	$popup/LineEdit.text = name

func _on_close_pressed():
	OS.hide_virtual_keyboard()
	queue_free()
	pass # Replace with function body.


func _on_close_button_up():
	$popup/close.modulate = Color("ffffff")
	pass # Replace with function body.


func _on_close_button_down():
	$popup/close.modulate = Color("f9ed8b")
	pass # Replace with function body.

func _on_Submit_pressed():
	OS.hide_virtual_keyboard()
	if $popup/LineEdit.text != "" :
		#get_parent().updateUserInfo($popup/LineEdit.text,"","")
		emit_signal("guset_login_successfully",$popup/LineEdit.text)
		queue_free()
	pass # Replace with function body.


func _on_btnBackground_pressed():
	OS.hide_virtual_keyboard()

	pass # Replace with function body.
