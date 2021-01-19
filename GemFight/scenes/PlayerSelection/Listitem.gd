#extends Panel
extends Control

signal player_select

var itemIndex = 0
var playSound = true


var item1_path = ""
var item2_path = ""

#When item open for Setting screen
var isFromSetting = false


func _on_item1Btn_pressed():
	if isFromSetting:
		emit_signal("player_select",$item1,itemIndex)
	else:
		resetAll()
		emit_signal("player_select",$item1,itemIndex)
		if playSound:
			$PlayerSelect.play()
	pass # Replace with function body.


func _on_item2Btn_pressed():
	if isFromSetting:
		emit_signal("player_select",$item2,itemIndex+1)
	else:
		resetAll()
		emit_signal("player_select",$item2,itemIndex+1)
		if playSound:
			$PlayerSelect.play()
	pass # Replace with function body.


func resetAll():
	$item2/Frame.texture = load(item2_path)#preload("res://art/PlayerSelection/player_frame.png")
	$item1/Frame.texture = load(item1_path)#preload("res://art/PlayerSelection/player_frame.png")
	

func selectItem(index):
	playSound = true
	if index % 2 == 0:
		#2nd item
		_on_item2Btn_pressed()
	else:
		#1st item
		_on_item1Btn_pressed()
		pass

func setDataToControls(data,index):
	if index % 2 == 0:
		$item1/item1Btn/Label.text = data["name"]
		item1_path = data["image"]
		$item1/pattern.texture = load(data["path"])
		$item1/Frame.texture = load(data["image"])
	else:
		$item2/item2Btn/Label2.text = data["name"]
		$item2/pattern.texture = load(data["path"])
		$item2/Frame.texture = load(data["image"])
		item2_path = data["image"]



func set_as_selected(index):
	if index % 2 == 0:
		$item2.modulate = Color("5a5353")
	else:
		$item1.modulate = Color("5a5353")
