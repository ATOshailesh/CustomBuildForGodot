class PlayerPattern:
	
	func _init():
		pass
	
	var pattern_chunli = [
		['y','y','r','r','g','g'],
		['y','y','r','r','g','g'],
		['r','r','g','g','b','b'],
		['r','r','g','g','b','b'],
	]
	
	var pattern_donovan = [
		['g','g','g','b','b','b'],
		['g','g','g','b','b','b'],
		['r','y','r','y','r','y'],
		['r','y','r','y','r','y'],
	]
	
	var pattern_felicia = [
		['g','b','b','r','r','y'],
		['g','b','b','r','r','y'],
		['g','r','r','b','b','y'],
		['g','r','r','b','b','y'],
	]
	
	var pattern_hsienko = [
		['g','g','r','r','y','y'],
		['b','g','g','r','r','y'],
		['b','b','g','g','r','r'],
		['y','b','b','g','g','r'],
	]
	
	
	var pattern_ken = [
		['y','y','y','y','y','y'],
		['b','b','b','b','b','b'],
		['g','g','g','g','g','g'],
		['r','r','r','r','r','r'],
	]
	
	
	var pattern_morrigan = [
		['y','b','g','g','b','y'],
		['y','b','g','g','b','y'],
		['b','y','r','r','y','b'],
		['b','y','r','r','y','b'],
	]
	
	var pattern_ryu = [
		['r','g','b','y','r','g'],
		['r','g','b','y','r','g'],
		['r','g','b','y','r','g'],
		['r','g','b','y','r','g'],
	]
	
	var pattern_sakura = [
		['g','b','b','b','b','y'],
		['g','r','r','r','r','y'],
		['g','b','b','b','b','y'],
		['g','r','r','r','r','y'],
	]
	
	####Secret players Counter Pattern
	
	var pattern_akuma = [
		['r','y','b','g','r','y'],
		['y','b','g','r','y','b'],
		['b','g','r','y','b','g'],
		['g','r','y','b','g','r'],
	]
	
	var pattern_dan = [
		['r','r','r','r','r','r'],
		['r','r','r','r','r','r'],
		['r','r','r','r','r','r'],
		['r','r','r','r','r','r'],
	]
	
	var pattern_devilot = [
		['y','r','g','b','y','r'],
		['b','y','r','g','b','y'],
		['g','b','y','r','g','b'],
		['r','g','b','y','r','g'],
	]
	
	func getPatternFromIndex(index):
		if index == 0:
			return pattern_ryu
		elif index == 1:
			return pattern_chunli
		elif index == 2:
			return pattern_sakura
		elif index == 3:
			return pattern_ken
		elif index == 4:
			return pattern_morrigan
		elif index == 5:
			return pattern_hsienko
		elif index == 6:
			return pattern_donovan
		elif index == 7:
			return pattern_felicia
		elif index == 8:
			return pattern_dan
		elif index == 9:
			return pattern_akuma
		elif index == 10:
			return pattern_devilot
		else:
			return pattern_sakura
	
	func getPatternCharacter(index):
		if index == 0:
			return "dragon"
		elif index == 1:
			return "swordman"
		elif index == 2:
			return "robomachine"
		elif index == 3:
			return "xmachine"
		elif index == 4:
			return "knight"
		elif index == 5:
			return "sugun"
		elif index == 6:
			return "golem"
		elif index == 7:
			return "ninja"
		elif index == 8:
			return "geeky"
		elif index == 9:
			return "archer"
		
	
	func getPlayerInfo(index):
		
		if index == 0:
			#ryu
			return {"name":"Dragon","path":"res://art/PlayerSelection/Patterns/ryu.png",
				"image":"res://art/PlayerSelection/Game_Player/player_1_1.png",
				"image_flip":"res://art/PlayerSelection/Game_Player/player_1.png",
				"round_image" : "res://art/settings/Player Round/drago.png",
				"description" : getPlayerDescription(index),
				"left_img" : "res://art/playscreenimg/player_1.png",
				"right_img" : "res://art/playscreenimg/player_1_1.png"
				}
		elif index == 1:
			#chunli
			return {"name":"Swordman","path":"res://art/PlayerSelection/Patterns/chunli.png",
			"image":"res://art/PlayerSelection/Game_Player/player_3_1.png",
			"image_flip":"res://art/PlayerSelection/Game_Player/player_3.png",
			"round_image" : "res://art/settings/Player Round/swordman.png",
			"description" : getPlayerDescription(index),
			"left_img" : "res://art/playscreenimg/player_2.png",
			"right_img" : "res://art/playscreenimg/player_2_2.png"
			}
		elif index == 2:
			#sakura
			return {"name":"Robo","path":"res://art/PlayerSelection/Patterns/sakura.png",
			"image":"res://art/PlayerSelection/Game_Player/player_4_1.png",
			"image_flip":"res://art/PlayerSelection/Game_Player/player_4.png",
			"round_image" : "res://art/settings/Player Round/xmachine.png",
			"description" : getPlayerDescription(index),
			"left_img" : "res://art/playscreenimg/player_5.png",
			"right_img" : "res://art/playscreenimg/player_5_5.png"
			}
		elif index == 3:
			#Ken
			return {"name":"XMachine","path":"res://art/PlayerSelection/Patterns/Ken.png",
			"image":"res://art/PlayerSelection/Game_Player/player_2_1.png",
			"image_flip":"res://art/PlayerSelection/Game_Player/player_2.png",
			"round_image" : "res://art/settings/Player Round/robo.png",
			"description" : getPlayerDescription(index),
			"left_img" : "res://art/playscreenimg/player_4.png",
			"right_img" : "res://art/playscreenimg/player_4_4.png"
			}
		elif index == 4:
			#morrigan
			return {"name":"Knight","path":"res://art/PlayerSelection/Patterns/morrigan.png",
			"image":"res://art/PlayerSelection/Game_Player/player_5_1.png",
			"image_flip":"res://art/PlayerSelection/Game_Player/player_5.png",
			"round_image" : "res://art/settings/Player Round/knight.png",
			"description" : getPlayerDescription(index),
			"left_img" : "res://art/playscreenimg/player_3.png",
			"right_img" : "res://art/playscreenimg/player_3_3.png"
			} 
		elif index == 5:
			#hsienko
			return {"name":"Sugun","path":"res://art/PlayerSelection/Patterns/hsienko.png",
			"image":"res://art/PlayerSelection/Game_Player/player_6_1.png",
			"image_flip":"res://art/PlayerSelection/Game_Player/player_6.png",
			"round_image" : "res://art/settings/Player Round/sugun.png",
			"description" : getPlayerDescription(index),
			"left_img" : "res://art/playscreenimg/player_6.png",
			"right_img" : "res://art/playscreenimg/player_6_6.png"
			}
		elif index == 6:
			#donovan
			return {"name":"Golem","path":"res://art/PlayerSelection/Patterns/donova.png",
			"image":"res://art/PlayerSelection/Game_Player/player_7_1.png",
			"image_flip":"res://art/PlayerSelection/Game_Player/player_7.png",
			"round_image" : "res://art/settings/Player Round/golem.png",
			"description" : getPlayerDescription(index),
			"left_img" : "res://art/playscreenimg/player_7.png",
			"right_img" : "res://art/playscreenimg/player_7_7.png"
			}
		elif index == 7:
			#felicia
			return {"name":"Ninja","path":"res://art/PlayerSelection/Patterns/felicia.png",
			"image":"res://art/PlayerSelection/Game_Player/player_8_1.png",
			"image_flip":"res://art/PlayerSelection/Game_Player/player_8.png",
			"round_image" : "res://art/settings/Player Round/ninja.png",
			"description" : getPlayerDescription(index),
			"left_img" : "res://art/playscreenimg/player_8.png",
			"right_img" : "res://art/playscreenimg/player_8_8.png"
			}
		elif index == 8:
			#dan
			return {"name":"Geeky","path":"res://art/PlayerSelection/Patterns/dan.png",
			"image":"res://art/PlayerSelection/Game_Player/player_9_1.png",
			"image_flip":"res://art/PlayerSelection/Game_Player/player_9.png",
			"round_image" : "res://art/settings/Player Round/geeky.png",
			"description" : getPlayerDescription(index),
			"left_img" : "res://art/playscreenimg/player_9.png",
			"right_img" : "res://art/playscreenimg/player_9_9.png"
			}
		elif index == 9:
			#akuma
			return {"name":"Archer","path":"res://art/PlayerSelection/Patterns/akuma.png",
			"image":"res://art/PlayerSelection/Game_Player/player_10_1.png",
			"image_flip":"res://art/PlayerSelection/Game_Player/player_10.png",
			"round_image" : "res://art/settings/Player Round/archery.png",
			"description" : getPlayerDescription(index),
			"left_img" : "res://art/playscreenimg/player_10.png",
			"right_img" : "res://art/playscreenimg/player_10_10.png"
			}
	
	func getPlayerDescription(index):
		if index == 0:
			return "Dragon is able to breathe fire. he shoots fireballs from his mouth. he charges flames in his mouth before releasing them as a high-intensity wave of fire."
		elif index == 1:
			return "The sword is imbued with dark magic, allowing it to cut through almost anything. Swordsman also has a few chain skills that can be used after his main skills to increase his arsenal of attacks."
		elif index == 2:
			return "Robo is able to shoot lasers out of his chest sockets with ease by simply sit. Robo right hand can turn into a powerful solar-powered arm cannon. many energy can overheat and even kill him."
		elif index == 3:
			return "Fires a powerful laser beam from XMachine head crest. XMachine uses the spiked treads feet to add force and power to the blow."
		elif index == 4:
			return "Knight has received training from some of the most experienced swordsmen in Hyrule. he always manages to find out the enemy's weaknesses."
		elif index == 5:
			return "Sugun is the best sharpshooter and marksman,  possessing great skill with his signature rifle. He's been able to score critical shots with a limited amount of time to aim, and has shown great precision with his marksmanship."
		elif index == 6:
			return "Golem are made of stones. he resistant to attacks because of their stone composition. Golem are not faster or clever, but he is incredibly strong! golem throw big stone on targeted monster."
		elif index == 7:
			return "Ninja utilises three Chakram. Each Chakram is circular and red, with silver spikes. Each Chakram has three spikes. ninja is very adept in the use of his weapon, he can throw them."
		elif index == 8:
			return "Geeky is a very strong player. He can smash a man's head with enough force to break through concrete with a single kick, dodge point-blank shots to the head, and take attacks from Hollows much larger than him."
		elif index == 9:
			return "Archery is an expert with a bow. Using only his bow skills and special arrows, he kill everyone. white Arrow carries a large amount of trick arrows, each with different function."
		
