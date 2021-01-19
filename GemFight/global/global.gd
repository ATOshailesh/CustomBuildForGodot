extends Node

var selected_mode = 1 #Easy default
var auto_drop = false
var isWin = false
var isFromGame = false
var isShowInstruction = false

var AI_Play_Index = []
var P1_Win_Count = 0
var P1_Win_Round = 0
var P1_lose_Round = 0

var EASY_GAME = 4
var NORMAL_GAME = 8
var HARD_GAME = 8

enum GameState {RUNNING,GAMEOVER,NONE,PAUSE}
enum GamePlayer {SINGLE,MULTI}
enum GameMode {EASY,NORMAL,HARD}
enum GemTypes {NORMAL,CRASH,COUNTER,DIAMOND}
enum PlayerMode {AI,PLAYER,NONE}


var DiamondGemLoader = preload("res://scenes/pieces/diamond_gem/Diamond_Piece.tscn")
var CrashGem = preload("res://scenes/pieces/crash_gem/Green_CrashPiece.tscn")
var possible_pieces = [


preload("res://scenes/pieces/Pink_Piece.tscn"),
preload("res://scenes/pieces/Green_Piece.tscn"),
preload("res://scenes/pieces/Blue_Piece.tscn"),
preload("res://scenes/pieces/Yellow_Piece.tscn"),

preload("res://scenes/pieces/crash_gem/Red_CrashPiece.tscn"),
preload("res://scenes/pieces/crash_gem/Green_CrashPiece.tscn"),
preload("res://scenes/pieces/crash_gem/Blue_CrashPiece.tscn"),
preload("res://scenes/pieces/crash_gem/Yellow_CrashPiece.tscn")

]


func get_gemFromData(type,color):
	#type : n c d
	if type == "d":
		return DiamondGemLoader
	elif type == "n":
		match color:
			"r":
				return possible_pieces[0]
			"g":
				return possible_pieces[1]
			"b":
				return possible_pieces[2]
			"y":
				return possible_pieces[3]
	elif type == "c":
		match color:
			"r":
				return possible_pieces[4]
			"g":
				return possible_pieces[5]
			"b":
				return possible_pieces[6]
			"y":
				return possible_pieces[7]


var posible_pieces_priority = [ 5,5,5,5, 2,2,2,2 ]

var counter_pieces = []
var playerPattern = [
	['y','y','r','r','g','g'],
	['y','y','r','r','g','g'],
	['r','r','g','g','b','b'],
	['r','r','g','g','b','b'],
]


#Player selection for counter pattern
var p1Index = 0
var p2Index = 2



var player1Score = 0
var pairManager
var selectColor = "r"
var isCrashOn = "n" #n,c,co
var isPlayerWin = false

#For Networked player 
var otherPlayerId = 1
var isHost = true
var isNetworked = false
var socketMrg


#Game Center Obje
var ios_GameCenter
var admobObj

#WebSocket Address
var WEBSOCKET_URL = "ws://52.86.161.208:9003"

var userData = null
var userTexture