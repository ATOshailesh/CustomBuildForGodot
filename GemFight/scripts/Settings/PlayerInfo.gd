extends Control

const Listitem = preload("res://scenes/PlayerSelection/Listitem.tscn")

var colorDefault = Color("ffffff")
var colorPressed = Color("f7ec38")

var objePattern
var xIndex = 0
var items = []

func _ready():
	objePattern = preload("res://scripts/PlayerPattern/PlayerPattern.gd").PlayerPattern.new()
	for i in 5:
		addItem(xIndex)
		xIndex += 2

func addItem(index):
	var new_style = StyleBoxFlat.new()
	new_style.bg_color = Color(0,0,0,0)
	
	var item = Listitem.instance()
	item.itemIndex = index
	item.rect_min_size = Vector2(335,200)

	$MarginContainer/ScrollContainer/VBoxContainer.add_child(item)
	item.set("custom_styles/panel",new_style)
	
	item.get_node("item1").set("custom_styles/panel",new_style)
	item.get_node("item2").set("custom_styles/panel",new_style)
	item.connect("player_select",self,"_selectedItem")
	item.isFromSetting = true
	item.setDataToControls(objePattern.getPlayerInfo(index),index)
	item.setDataToControls(objePattern.getPlayerInfo(index+1),index+1)
	
	
	##Create array
	items.append(item)
	items.append(item)



func _selectedItem(nowSelected,index) :
	print("index :",index)
	var infoPopUp = preload("res://scenes/Settings/Infopopup.tscn").instance()
	infoPopUp.loadWithData(objePattern.getPlayerInfo(index))
	add_child(infoPopUp)
	infoPopUp.connect("dismiss_infopopup",self,"close_infopopup")
	$MarginContainer/ScrollContainer.stopScroll = true
	pass

func close_infopopup():
	$MarginContainer/ScrollContainer.stopScroll = false
	pass
func _on_Back_button_up():
	$Back.modulate = colorDefault
	pass # Replace with function body.


func _on_Back_button_down():
	$Back.modulate = colorPressed

func _on_Back_pressed():
	$TouchSound.play()
	queue_free()
	pass # Replace with function body.


func _on_ScrollContainer_scroll_ended():
	print("stop")
	pass # Replace with function body.


func _on_ScrollContainer_scroll_started():
	print("start")
	pass # Replace with function body.
