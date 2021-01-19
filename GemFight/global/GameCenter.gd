extends Node

class GameCenterInfo:
	var GameCenter
	func _init():
		if Engine.has_singleton("GameCenter"):
			GameCenter = Engine.get_singleton("GameCenter")
		pass
	
	func post_score(score):
		if GameCenter != null:
			var result = GameCenter.post_score( { "score": score, "category": "my_leaderboard", })
			check_Events()
		
	func check_Events():
		while GameCenter.get_pending_event_count() > 0:
			#
			print(".")
		
	
