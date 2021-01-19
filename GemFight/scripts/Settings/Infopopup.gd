extends Control

signal dismiss_infopopup

func _ready():
	pass

func loadWithData(data):
	$Container/pattern.texture = load(data["path"])
	$Control/playericon.texture = load(data["round_image"])

	$Container/player_name.text = data["name"]
	$Container/description.text = data["description"]
	pass

func _on_Button_pressed():
	emit_signal("dismiss_infopopup")
	queue_free()
	pass # Replace with function body.


func _on_Button_button_up():
	$Container/Button.modulate = Color("ffffff")
	pass # Replace with function body.


func _on_Button_button_down():
	$Container/Button.modulate = Color("dbdc64")
	pass # Replace with function body.
