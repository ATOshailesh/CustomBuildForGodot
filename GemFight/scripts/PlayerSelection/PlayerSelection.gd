extends Control

signal go_connect
const Listitem = preload("res://scenes/PlayerSelection/Listitem.tscn")

var objePattern 

var prevSelectedItem
var patternIndex

var isTwoPlay = false

var items = []
var isAISelection = false

var totalPlayer = [0,1,2,3,4,5,6,7,8,9]
var goForAISelection = false

var colorDefault = Color("ffffff")
var colorPressed = Color("f7ec38")

func _ready():
	objePattern = preload("res://scripts/PlayerPattern/PlayerPattern.gd").PlayerPattern.new()
	$SearchOpponent.connect("cancel_search_opponent",self,"_cancel_search_opponent")
	
	for i in GLOBAL.AI_Play_Index:
		totalPlayer.erase(i)
	var xIndex = 0
	
	for i in 5:
		addItem(xIndex)
		xIndex += 2
	
	if goForAISelection:
		_AI_Selection()



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
	
	item.setDataToControls(objePattern.getPlayerInfo(index),index)
	item.setDataToControls(objePattern.getPlayerInfo(index+1),index+1)
	
	##Create array
	items.append(item)
	items.append(item)
	
	if GLOBAL.AI_Play_Index.has(index):
		item.set_as_selected(index)
	if GLOBAL.AI_Play_Index.has(index+1):
		item.set_as_selected(index+1)
	

func randomSelectionAnim():
	
	for i in 20:
		var t = Timer.new()
		t.set_wait_time(0.1)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
		t.queue_free()
		randomize()
		var num = totalPlayer[randi() % totalPlayer.size()]#randi() % items.size()
		items[num].selectItem(num)
		if i == 19:
			var t2 = Timer.new()
			t2.set_wait_time(0.5)
			t2.set_one_shot(true)
			self.add_child(t2)
			t2.start()
			yield(t2, "timeout")
			t2.queue_free()
			GLOBAL.p2Index = patternIndex
			GLOBAL.AI_Play_Index.append(num)
			print("GLOBAL.AI_Play_Index :",GLOBAL.AI_Play_Index)
			allSelectionDone()
	pass



func _selectedItem(nowSelected,index):
	resetPrevItem()
	nowSelected.get_node("Selected").visible = true
	nowSelected.get_node("Frame").texture = preload("res://art/PlayerSelection/player_frame_selected.png")
	nowSelected.get_node("pattern").visible = true
	prevSelectedItem = nowSelected
	$btnTick.visible = true
	patternIndex = index

func resetPrevItem():
	if prevSelectedItem != null:
		
		prevSelectedItem.get_node("Frame").texture = preload("res://art/PlayerSelection/player_frame.png")
		prevSelectedItem.get_node("Selected").visible = false
		prevSelectedItem.get_node("pattern").visible = false
		prevSelectedItem.get_parent().resetAll()
		prevSelectedItem = null

func _on_Back_pressed():
	$TouchSound.play()
	NetCmd._disconnect()
	var dd = get_tree().change_scene("res://scenes/MainMenu/LevelMockup.tscn")

func _on_btnTick_pressed():
	GLOBAL.p1Index = patternIndex
	$TouchSound.play()
	if isTwoPlay:
		$SearchOpponent.show()
		emit_signal("go_connect")
	else:
		_AI_Selection()
		
func _cancel_search_opponent(isBackHome):
	NetCmd.user_searching_oppponent(false)
	if isBackHome:
		_on_Back_pressed()
		return
		var timer = Timer.new()
		timer.set_wait_time(1)
		timer.set_one_shot(true)
		self.add_child(timer)
		timer.start()
		yield(timer, "timeout")
		timer.queue_free()
		_on_Back_pressed()
	
func allSelectionDone():
	get_tree().change_scene("res://scenes/TwoPlayer/Home.tscn")

func _AI_Selection():
	for item in items:
		item.get_node("item1/Button").disabled = true
		item.get_node("item2/Button").disabled = true
	
	isAISelection = true
	var t2 = Timer.new()
	t2.set_wait_time(0.5)
	t2.set_one_shot(true)
	self.add_child(t2)
	t2.start()
	yield(t2, "timeout")
	t2.queue_free()
	randomSelectionAnim()

func _on_btnTick_button_down():
	$btnTick.modulate = colorPressed
	pass # Replace with function body.


func _on_btnTick_button_up():
	$btnTick.modulate = colorDefault
	pass # Replace with function body.


func _on_Back_button_up():
	$Back.modulate = colorDefault
	pass # Replace with function body.


func _on_Back_button_down():
	$Back.modulate = colorPressed
	pass # Replace with function body.
