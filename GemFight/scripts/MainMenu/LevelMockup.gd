extends Node

var colorDefault = Color("ffffff")
var colorPressed = Color("f7ec38")

var facebookObj
var facebook_app_id = "435550843916201"

var googleObj
var google_id = "707064715330-pr7kcnoc5ao1n398gipcs2u0g899tiec.apps.googleusercontent.com"
	#"707064715330-pr7kcnoc5ao1n398gipcs2u0g899tiec.apps.googleusercontent.com"

var share = null # our share singleton 

var userData = {"name":"","email":"","photo":"","mute":"0"}
var FileSaver = preload("res://global/save_data.gd").new()

var SETTINGNode = preload("res://scenes/Settings/SettingMenu.tscn")
var childNode 

func _ready():
	FileSaver.load_data()
	print("GLOBAL.userData :",GLOBAL.userData)
	if GLOBAL.userData != null:
		if GLOBAL.userData.has("name"):
			if GLOBAL.userTexture != null:
				$TopPannel/VBoxContainer/TextureRect/Button.icon = GLOBAL.userTexture
			$TopPannel/VBoxContainer/lblUseName.text = GLOBAL.userData["name"]
			updateUserInfo(GLOBAL.userData.name,GLOBAL.userData.email,GLOBAL.userData.photo)
		else:
			$TopPannel/VBoxContainer/lblUseName.text= "Player1"
			#$TopPannel/VBoxContainer/TextureRect/Button.icon = null
	
	$BgSound.play()
	$TopPannel/HBoxContainer/btnSetting.connect("pressed",self,"_onSignal_Setting_Pressed")
	$TopPannel/HBoxContainer/btnShare.connect("pressed",self,"_onSignal_Share_Pressed")
	$TopPannel/VBoxContainer/lblUseName/btnName.connect("pressed",self,"_onSignal_UserName_Pressed")
	
	$TopPannel/HBoxContainer/btnShare.connect("button_down",self,"_onbtnShare_down")
	$TopPannel/HBoxContainer/btnShare.connect("button_up",self,"_onbtnShare_up")
	
	$TopPannel/HBoxContainer/btnSetting.connect("button_down",self,"_onbtnSetting_down")
	$TopPannel/HBoxContainer/btnSetting.connect("button_up",self,"_onbtnSetting_up")
	
#	$MiddelPannel/HBoxContainer/btnSetting.connect("pressed",self,"_onSignal_Setting_Pressed")
#	$MiddelPannel/HBoxContainer/btnShare.connect("pressed",self,"_onSignal_Share_Pressed")

	if Engine.has_singleton("GodotFacebook"):
		facebookObj = Engine.get_singleton("GodotFacebook")
		facebookObj.init(facebook_app_id)
		facebookObj.setFacebookCallbackId(get_instance_id())

	if Engine.has_singleton("GoogleLogin"):
		googleObj = Engine.get_singleton("GoogleLogin")
		googleObj.setGoogleCallbackId(self.get_instance_id())
		googleObj.init(google_id)
	
	if Engine.has_singleton("GodotShare"):
		share = Engine.get_singleton("GodotShare")
	
	GLOBAL.admobObj = preload("res://scripts/Admob/AdmobManger.gd").AdmobManager.new()
	
	#$HTTPRequest.request("http://docs.godotengine.org/en/stable/_static/docs_logo.png")
	#$HTTPRequest.request("https://i.ibb.co/Hqxrwqq/Test-Power.png")
	#$HTTPRequest.request("https://i.ibb.co/YPDQS9n/89663605-instagram-logo-976.jpg")
	#$HTTPRequest.request("https://via.placeholder.com/500")
	#$HTTPRequest.request("https://lh3.googleusercontent.com/a-/AAuE7mCRvBvWIL5Y4kOcMRUFazrZqT1VBqFJMbzvqkY7")
	#$HTTPRequest.request("https://platform-lookaside.fbsbx.com/platform/profilepic/?asid=617899572064921&height=70&width=70&ext=1562494484&hash=AeQcl6eFsuC6U1u3")
	#$HTTPRequest.request("http://ichef.bbci.co.uk/news/976/cpsprodpb/C5CC/production/_89663605_instagram_logo_976.jpg")
	#$HTTPRequest.request("http://vim.nrvana.com/wp-content/uploads/2016/10/facebook-png-02-15.png")
	#$HTTPRequest.request("http://graph.facebook.com/517267866/picture?type=large") 
	#$HTTPRequest.request("https://imgnooz.com/sites/default/files/wallpaper/nature/60879/beautiful-red-rose-wallpapers-60879-1208025.jpg")
	
	#$HTTPRequest.request("https://vsccd8ns6b.execute-api.us-east-2.amazonaws.com/dev/users/2019_06_08_07_42_54_BbXfybB.png")
	#$HTTPRequest.request("https://s3.us-east-2.amazonaws.com/my-serverless-app-uploads/users/50xAUTO/2019_06_08_07_42_54_BbXfybB.png")
	#$HTTPRequest.request("https://vsccd8ns6b.execute-api.us-east-2.amazonaws.com/dev/users/2019_06_08_07_42_54_BbXfybB.png?width=100&hight=100")
	
#	var http_requests = HTTPRequest.new()
#	add_child(http_requests)
#	http_requests.connect("request_completed", self, "_http_request_completed")
#
#	var http_error = http_requests.request("https://via.placeholder.com/500")
#	if http_error != OK:
#		print("An error occurred in the HTTP request.")
#
## Called when the HTTP request is completed.
#func _http_request_completed(result, response_code, headers, body):
#	var image = Image.new()
#	var image_error = image.load_png_from_buffer(body)
#	if image_error != OK:
#		print("An error occurred while trying to display the image.")
#	image.resize(60,60,Image.INTERPOLATE_BILINEAR)	
#	var texture = ImageTexture.new()
#	texture.create_from_image(image)
#
#	# Assign to the child TextureRect node
#	$TextureRect.texture = texture

func resetUserData():
	FileSaver.clearAllData()
	$TopPannel/VBoxContainer/lblUseName.text= "Name"
	GLOBAL.userTexture = null
	#$TopPannel/VBoxContainer/TextureRect/Button.icon = null

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		if self.has_node("PlayerSelection"):
			self.get_node("PlayerSelection").queue_free()
		elif self.has_node("SettingMenu"):
			var setting = self.get_node("SettingMenu")
			if setting.has_node("PlayerInfo"):
				setting.get_node("PlayerInfo").queue_free()
			else:
				setting.queue_free()
		else:
			$MiddelPannel/PopupPanel.show()
			print("show quit")


func _onSignal_Share_Pressed():
	# if share was found, use it
	#showGameIntroduction()
	if share != null:
		share.shareText("Gem Fight","App  Link","http://atologistinfotech.com")
	
		
func _onSignal_Setting_Pressed():
	var objecSetting = SETTINGNode.instance()
	add_child(objecSetting)
	childNode = objecSetting
	pass

func _onSignal_UserName_Pressed():
		var loadPopup = preload("res://scenes/Login/Inputpopup.tscn").instance()
		loadPopup.connect("guset_login_successfully",self,"updateUserName")
		loadPopup.setName(userData["name"])
		add_child(loadPopup)
		
#	if facebookObj != null:
#		if facebookObj.isLoggedIn() :
#			facebookObj.logout()
#			print("Facebook logout successfully.")
#	if googleObj != null:
#		if googleObj.isLoggedIn():
#			googleObj.logout()
#			print("Google logout successfully.")
#
	#FileSaver.clearAllData()
	#$TopPannel/VBoxContainer/lblUseName.text= "Name"
	#$TopPannel/VBoxContainer/TextureRect/Button.icon = null

func updateUserName(_name):
	userData.name = _name
	$TopPannel/VBoxContainer/lblUseName.text = _name
	if GLOBAL.userData.has("name"):
		GLOBAL.userData["name"] = _name
	var mute = GLOBAL.userData["mute"]
	userData["mute"] = mute
	FileSaver._user_data = userData
	FileSaver.save_data()
	
func updateUserInfo(_name,email,image):
	userData.name = _name
	userData.email = email
	userData.photo = image
	
	var mute = GLOBAL.userData["mute"]
	userData["mute"] = mute
	FileSaver._user_data = userData
	
	FileSaver.save_data()
	#.photo = "https://lh3.googleusercontent.com/a-/AAuE7mCRvBvWIL5Y4kOcMRUFazrZqT1VBqFJMbzvqkY7"
	if userData.photo == "":
		$Loader.hide()
		return
	
	var http_error = $HTTPRequest.request(userData.photo)
	if http_error != OK:
		print("An error occurred in the HTTP request.")
	$TopPannel/VBoxContainer/lblUseName.text = _name

func _onbtnShare_down():
	$TopPannel/HBoxContainer/btnShare.modulate = colorPressed

func _onbtnShare_up():
	$TopPannel/HBoxContainer/btnShare.modulate = colorDefault

func _onbtnSetting_down():
	$TopPannel/HBoxContainer/btnSetting.modulate = colorPressed

func _onbtnSetting_up():
	$TopPannel/HBoxContainer/btnSetting.modulate = colorDefault


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	
	print("Get success response of photourl : ",result,response_code,body,headers)
	var image = Image.new()
	
	var image_error = image.load_jpg_from_buffer(body) # image.load_png_from_buffer(body)
	if image_error != OK:
		print("An error occurred while trying to display the image.")
		var err = image.load_png_from_buffer(body)
		if err != OK:
			print("PNG File error")
	image.resize(60,60,Image.INTERPOLATE_BILINEAR)
	
#	var image_save_path = "user://user_image.png" #OS.get_user_data_dir() + "/tmp.png"
#	var err = image.save_png(image_save_path) #("user://user_image.png")#("res://userData/user_image.png")
#	if err != OK:
#		print("Fail save user image",err)
#	else:
#		print("Save user image")
#		var img = Image.new()
#		img.load(image_save_path)
#		print("IMG : ",img)
#		print("IMG : ",image)
#		var itex = ImageTexture.new()
#		itex.create_from_image(img)
#		$TopPannel/VBoxContainer/TextureRect/Button.icon = itex
	
	var texture = ImageTexture.new()
	texture.create_from_image(image)

	# Assign to the child TextureRect node
	#$TopPannel/VBoxContainer/TextureRect.texture = texture
	print("texture: ",texture)
	$TopPannel/VBoxContainer/TextureRect/Button.icon = texture
	GLOBAL.userTexture = texture
	#$TopPannel/VBoxContainer/TextureRect.texture = texture
	$Loader.hide()
	pass # Replace with function body.

# Introducation of game
func showGameIntroduction():
	#Player1Grid.gmState = GLOBAL.GameState.PAUSE
	#Player2Grid.gmState = GLOBAL.GameState.PAUSE
	var popup = preload("res://scenes/popup/Introduction/crashIntro.tscn")
	var obj = popup.instance()
	obj.connect("finish_introduction",self,"finish_introducation")
	add_child(obj)
	
func finish_introducation():
	print("Finish")
	#Player1Grid.gmState = GLOBAL.GameState.RUNNING
	#Player2Grid.gmState = GLOBAL.GameState.RUNNING
