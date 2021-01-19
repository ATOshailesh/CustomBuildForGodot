	extends Control

var facebookObj
var facebook_app_id = "2438722536360316"
 #"421980185028061" #"435550843916201"

var googleObj
var google_id = "999742218575-d9mtedem0fh3o95e485aufdfql8bp3fd.apps.googleusercontent.com"
var google_id_IOS = "999742218575-662nsvicv53t79gdk1h7h5f7ig6ua15a.apps.googleusercontent.com"
# "999742218575-h9mivp9rl99ati8elrbsbsia3ao3cdb0.apps.googleusercontent.com"
# My : "999742218575-d9mtedem0fh3o95e485aufdfql8bp3fd.apps.googleusercontent.com"
#pratik : "707064715330-pr7kcnoc5ao1n398gipcs2u0g899tiec.apps.googleusercontent.com"

var userData = {"name":"","email":"","photo":"","mute":"0"}
var FileSaver = preload("res://global/save_data.gd").new()
var lastAction

func _ready():
	isPlayGameInstroduction()
	FileSaver.load_data()
	
	if OS.get_name() == "iOS":
		google_id = google_id_IOS
		
	if Engine.has_singleton("GodotFacebook"):
		facebookObj = Engine.get_singleton("GodotFacebook")
		facebookObj.init(facebook_app_id)
		facebookObj.setFacebookCallbackId(get_instance_id())
	
	if Engine.has_singleton("GoogleLogin"):
		googleObj = Engine.get_singleton("GoogleLogin")
		googleObj.setGoogleCallbackId(self.get_instance_id())
		googleObj.init(google_id)

func openConnectionFailPopup():
	var connectionPopup = preload("res://scenes/popup/ConnectionFailPopup.tscn").instance()
	connectionPopup.connect("retry",self,"_retry_login")
	add_child(connectionPopup)
	
func _retry_login():
	if lastAction == "facebook":
		_on_facebook_pressed()
	elif lastAction == "google":
		_on_google_pressed()
		
func _on_facebook_pressed():
	if facebookObj != null:
		showLoader()
		facebookObj.login(["public_profile", "email"])


func _on_facebook_button_up():
	$popup/buttons/facebook.modulate = Color("ffffff")
	pass # Replace with function body.


func _on_facebook_button_down():
	$popup/buttons/facebook.modulate = Color("74aaee")
	pass # Replace with function body.


func _on_google_pressed():
	#$ClickSound.play()
	if googleObj != null:
		showLoader()
		if OS.get_name() == "iOS":
			googleObj.login(googleObj.getGoogleCallbackId())
		elif OS.get_name() == "Android":
			googleObj.login(["read"])



func _on_google_button_up():
	$popup/buttons/google.modulate = Color("ffffff")
	pass # Replace with function body.


func _on_google_button_down():
	$popup/buttons/google.modulate = Color("ed8282")
	pass # Replace with function body.


func _on_guest_pressed():
	#$ClickSound.play()
	var loadPopup = preload("res://scenes/Login/Inputpopup.tscn").instance()
	loadPopup.connect("guset_login_successfully",self,"_guest_login_success")
	add_child(loadPopup)
	
	#showMainScreen()
	pass # Replace with function body.


func _on_guest_button_up():
	$popup/buttons/guest.modulate = Color("ffffff")
	pass # Replace with function body.


func _on_guest_button_down():
	$popup/buttons/guest.modulate = Color("f3e283")
	pass # Replace with function body.

func _guest_login_success(name):
	updateUserInfo(name,"","")
	
#Facebook Login Callbacks
func login_success(token):
	print('Facebook login success: %s'%token)
	getUserDataFromFB()

func login_cancelled():
	print('Facebook login cancelled')
	hideLoader()

func login_failed(error):
	print('Facebook login failed: %s'%error)
	lastAction = "facebook"
	hideLoader()
	openConnectionFailPopup()
	
func getUserDataFromFB():
	var callbckID = facebookObj.getFacebookCallbackId()
	facebookObj.userProfile(callbckID,"_fetch_UserProfile")

func _fetch_UserProfile(data):
	print("Facebook Data : ",data)
	showLoader()
	if OS.get_name() == "iOS":
		updateUserInfo(data["first_name"],data["email"],data.picture.data.url)
	elif OS.get_name() == "Android":
		updateUserInfo(data.first_name,data.email,data.picture.data.url)

#Google Login Callbacks
func Googlelogin_success(result):
	print("Google login success : ",result)
	showLoader()
	if OS.get_name() == "iOS":
		updateUserInfo(result["givenName"],result["email"],result["profileUrl"])
	elif OS.get_name() == "Android":
		updateUserInfo(result.name,result.email,result.photourl)

func google_request_failed(error):
	print("Google login fail : ",error)
	lastAction = "google"
	hideLoader()
	openConnectionFailPopup()

func updateUserInfo(_name,email,image):

	userData.name = _name
	userData.email = email
	userData.photo = image
	if GLOBAL.userData != null:
		print("Get data")
	FileSaver._user_data = userData
	FileSaver.save_data()
	hideLoader()
	showMainScreen()
	

func showMainScreen():
	var dd = get_tree().change_scene("res://scenes/MainMenu/LevelMockup.tscn")
	
# Loader show / hide

func showLoader():
	$Loader/AnimationPlayer.play("round")
	$Loader.show()
	
func hideLoader():
	$Loader.hide()
	var t = Timer.new()
	t.set_wait_time(0.2)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free()
	$Loader/AnimationPlayer.stop()
	
func isPlayGameInstroduction():
	var file = File.new()
	var path = "user://setting.dat"
	if(not file.file_exists(path)):
		GLOBAL.isShowInstruction = true
		file.open(path,File.WRITE)
		file.store_var("")
		file.close()
	else:
		GLOBAL.isShowInstruction = false
