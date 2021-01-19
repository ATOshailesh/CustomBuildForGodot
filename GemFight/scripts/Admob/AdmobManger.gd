class AdmobManager:
	
	var instance_id
	var admob

	var isReal = true # For admob id is live
	var isTop = false
	var adBannerId = "ca-app-pub-3940256099942544/2934735716" # [Replace with your Ad Unit ID and delete this message.]
	var adInterstitialId = "ca-app-pub-3940256099942544/4411468910" # [Replace with your Ad Unit ID and delete this message.]
	var adRewardedId = "ca-app-pub-3940256099942544/5224354917" # [There is no testing option for rewarded videos, so you can use this id for testing]

	func _init():
		instance_id = get_instance_id()
		if Engine.has_singleton("AdMob"):
			print("Get abmob")
			admob = Engine.get_singleton("AdMob")
			print("inastance ID: ",instance_id)
			print("admob : ",admob)
			admob.init(isReal, instance_id)
			#loadBanner()
			loadInterstitial()
			#loadRewardedVideo()
		else:
			print("Not Get abmob")
		pass
		
	########################
	#### ADMOB FUNCTION ####
	########################
	
	func loadBanner():
		if admob != null:
			admob.loadBanner(adBannerId, isTop)
	
	func loadInterstitial():
		if admob != null:
			admob.loadInterstitial(adInterstitialId)
			print("LOADED")
		
	func loadRewardedVideo():
		if admob != null:
			admob.loadRewardedVideo(adRewardedId)
		
	# Admod Event
	
	func _on_BtnBanner_toggled(pressed):
		if admob != null:
			if pressed: admob.showBanner()
			else: admob.hideBanner()
	
	func _on_BtnInterstitial_pressed():
		if admob != null:
			admob.showInterstitial()
		
	func _on_BtnRewardedVideo_pressed():
		if admob != null:
			admob.showRewardedVideo()
	
	func _on_admob_network_error():
		print("Network Error")
	
	func _on_admob_ad_loaded():
		print("Ad loaded success")
		#get_node("CanvasLayer/BtnBanner").set_disabled(false)
	
	func _on_interstitial_not_loaded():
		print("Error: Interstitial not loaded")
	
	func _on_interstitial_loaded():
		print("Interstitial loaded.")
		#get_node("CanvasLayer/BtnInterstitial").set_disabled(false)
		#_on_BtnInterstitial_pressed()
		
	func _on_interstitial_close():
		print("Interstitial closed")
		loadInterstitial()
		#get_node("CanvasLayer/BtnInterstitial").set_disabled(true)
	
	
	func _on_rewarded_video_ad_loaded():
		print("Rewarded loaded success")
		#get_node("CanvasLayer/BtnRewardedVideo").set_disabled(false)
	
	func _on_rewarded_video_ad_closed():
		print("Rewarded closed")
		#get_node("CanvasLayer/BtnRewardedVideo").set_disabled(true)
		#loadRewardedVideo()
	
	func _on_rewarded(currency, amount):
		print("Reward: " + currency + ", " + str(amount))
		#get_node("CanvasLayer/LblRewarded").set_text("Reward: " + currency + ", " + str(amount))
	
	func onResize():
		if admob != null:
			admob.resize()
			print("Resize")
