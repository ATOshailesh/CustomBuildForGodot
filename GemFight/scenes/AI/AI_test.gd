extends Control

# Declare member variables here. Examples:
# var a = 2
onready var Player2Grid = $Player2Grid

# Called when the node enters the scene tree for the first time.
func _ready():
	#GLOBAL.selected_mode = 2
	Player2Grid.startPlaying()
	pass # Replace with function body.

