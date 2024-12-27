extends Node
signal hit
signal characterSelect
signal gameOver
signal coinsCollectedSignal

var characters = ["res://images/snowTiger_stand.png","res://images/panda_stand_base.png","res://images/bear_stand.png","res://images/bunny_stand.png","res://images/pig_stand.png"]
var currentCharacter = 0

var soundOn = true
var menuMusic
var currentData: String
var savedData = ""
var unauthenticatedUser = true
var skipUpdateCharacter = false

var _ad_view : AdView

@export var game_scene: PackedScene
@export var menu_scene: PackedScene
@export var achievements_scene: PackedScene

var _sign_in_retries := 1

# Called when the node enters the scene tree for the first time.
func _ready():
	#var deviceId = OS.get_unique_id()
	#$DebugLabel.text = $DebugLabel.text + deviceId
	SnapshotsClient.game_loaded.connect(
		func(snapshot: SnapshotsClient.Snapshot):
			if !snapshot:
				#$DebugLabel.text = $DebugLabel.text + " snap not found" 
				print("snap shot not found")
				var saveData = {"coins": 0, "playerUnlocks": [true,false,false,false,false]}
				updateCoins(0)
				var jsonSaveData = JSON.stringify(saveData)
				var parsedData = JSON.parse_string(jsonSaveData)
				savedData = parsedData
				SnapshotsClient.save_game("playerData", "player data for Animal Dash", jsonSaveData.to_utf8_buffer())
				#$DebugLabel.text = $DebugLabel.text + "here1"
			else: 
				currentData = snapshot.content.get_string_from_utf8()
				var parsedData = JSON.parse_string(currentData)
				savedData = parsedData
				var currentPlayerCoins = parsedData["coins"]
				if currentPlayerCoins == null: 
					print("error on player coins")
					SnapshotsClient.load_game("playerData", true)
				#$DebugLabel.text = $DebugLabel.text + "from g_l" 
				updateCoins(currentPlayerCoins)
				updateCharacter()
				
				unauthenticatedUser = false
				#$CoinsLabel.text = currentPlayerCoins
	)
	
	SnapshotsClient.conflict_emitted.connect(
		func():
			pass
			#$DebugLabel.text = $DebugLabel.text + "snapshot conflict"
	)
	AchievementsClient.achievements_loaded.connect(
		func achievementsLoaded(achievements: Array[AchievementsClient.Achievement]):
			#$TitleText.text = $TitleText.text + " inside loaded callback "; 
			AchievementsClient.show_achievements()
	)
	SnapshotsClient.game_saved.connect(
		func(is_saved: bool, save_data_name: String, save_data_description: String):
			if is_saved:
				if !skipUpdateCharacter:
					updateCharacter()
				#$DebugLabel.text = $DebugLabel.text + "upc from s_g" 
				#updateCoins(savedData["coins"])
			else: 
				pass
				#$DebugLabel.text = $DebugLabel.text + " unable to save game"
	)
	if SignInClient == null or GodotPlayGameServices == null: 
		pass
		#$TitleText.text = "SignInClient is null"
	SignInClient.user_authenticated.connect(func(is_authenticated: bool):
		if not is_authenticated:
			pass
		else: 
			$GoogleSignIn.visible = false
			print("loading player data")
			#$DebugLabel.text = $DebugLabel.text + "trying to load data "
			SnapshotsClient.load_game("playerData", false)
	)
	updateCharacter()
	menuMusic = $MenuMusic
	#redoMainMenu() 
	if soundOn: 
		menuMusic.play()
	if not GodotPlayGameServices.android_plugin: 
		print("play game services not found")
		#$TitleText.text = $TitleText.text + "Play game services not found"
	else: 
		print("google sign in available")
		#$TitleText.text = $TitleText.text + "Play game services found"
	
	#The initializate needs to be done only once, ideally at app launch.
	var onInitializationCompleteListener = OnInitializationCompleteListener.new()
	onInitializationCompleteListener.on_initialization_complete = onAdInitializationComplete
	var request_configuration = RequestConfiguration.new()
	$DebugLabel.text = $DebugLabel.text + "calling init"
	MobileAds.initialize(onInitializationCompleteListener)
	$DebugLabel.text = $DebugLabel.text + " post init"
	#"F03226F1DD8EFC77"
	#,"2077EF9A63D2B398840261C8221A0C9B"
	if MobileAds: 
		request_configuration.test_device_ids = ["523a1b0eb5b6be122cd04bedf8035291","2077EF9A63D2B398840261C8221A0C9B"]
		MobileAds.set_request_configuration(request_configuration)
		_create_ad_view()
		check_initialization_status()
	
func check_initialization_status():
	$DebugLabel.text = $DebugLabel.text + "check init"
	var status = MobileAds.get_initialization_status()
	if status: 
		for adapter_name in status.adapter_status_map.keys():
			var adapter_status = status.adapter_status_map[adapter_name]
			$DebugLabel.text = $DebugLabel.text + "Adapter: " + adapter_name + "State: " + adapter_status.state + "Description: " + adapter_status.description
		
func onAdInitializationComplete(status : InitializationStatus): 
	print("banner ad initialization complete")
	$DebugLabel.text = $DebugLabel.text + " inside init"
	_create_ad_view()

func _create_ad_view() -> void:
	$DebugLabel.text = $DebugLabel.text + "inside create"
	#free memory
	if _ad_view:
		destroy_ad_view()

	var adListener = AdListener.new()
	adListener.on_ad_failed_to_load = func(load_ad_error : LoadAdError): 
		$DebugLabel.text = $DebugLabel.text + load_ad_error.message
		
	#$DebugLabel.text = $DebugLabel.text + " inside create"
	var unit_id = "ca-app-pub-3940256099942544/6300978111"

	_ad_view = AdView.new(unit_id, AdSize.BANNER, AdPosition.Values.BOTTOM_RIGHT)
	var ad_request = AdRequest.new()
	_ad_view.load_ad(ad_request)
	_ad_view.show()
	$DebugLabel.text = $DebugLabel.text + " aft load"
	
func destroy_ad_view(): 
	_ad_view.destroy()
	_ad_view = null
		
func _process(_delta):
	pass
	
func _on_button_pressed():
	skipUpdateCharacter = true
	$MenuMusic.stop()
	if soundOn: 
		$DashClick.play()
	$CharacterImage.visible = false
	$StartGame.visible = false
	$LeftButton.visible = false
	$RightButton.visible = false
	$GoogleSignIn.visible = false
	$TitleText.visible = false
	$Achievements.visible = false
	$SoundToggle.visible = false
	$CoinLabelSprite.visible = false
	$CoinsLabel.visible = false
	$LockIcon.visible = false
	$UnlockButton.visible = false
	$BackgroundImage.visible = false
	#remove_child($CharacterImage)
	#remove_child($StartGame)
	#remove_child($LeftButton)
	#remove_child($RightButton)
	var game = game_scene.instantiate()
	#get_tree().current_scene.queue_free()
	#get_tree().root.add_child(game)
	#get_tree().current_scene = game
	add_child(game)
	var characterName = characters[currentCharacter].replace("res://images/","").replace("_stand.png","").replace("_stand_base.png","")
	game.call("_on_sound_toggled", soundOn)
	game.call("prepareBackgroundSprite", characterName)
	game.call("setCurrentData", savedData)
	game.get_node("Player").call("_on_character_select", characterName)
	#emit_signal("characterSelect")
	game.connect("gameOver", _on_game_finished)
	#game.connect("coinsCollectedSignal", _on_coins_collected)
	
func updateCoins(amount): 
	$CoinsLabel.text = amount
	$CoinsLabel.visible = true
	
func _on_game_finished(): 
	if soundOn: 
		$HitSound.play()
	redoMainMenu()
	SnapshotsClient.load_game("playerData")
	print("on game finished")
	
func redoMainMenu(): 
	print("recreating main menu")
	if soundOn: 
		$MenuMusic.play()
	var menuElements = [$CharacterImage, $StartGame, $LeftButton, $RightButton, $GoogleSignIn, $TitleText, $Achievements, $SoundToggle, $CoinLabelSprite, $BackgroundImage]
	for element in menuElements: 
		print("making element visible")
		element.visible = true

func updateCharacter(): 
	print('updating character')
	#$DebugLabel.text = $DebugLabel.text + " " + str(currentCharacter)
	checkCharacterUnlock(currentCharacter)
	changeBackground(currentCharacter)
	
func changeBackground(currentCharacter): 
	match currentCharacter: 
		-1: 
			currentCharacter = 4
		-2: 
			currentCharacter = 3
		-3: 
			currentCharacter = 2
		-4: 
			currentCharacter = 1
			
	match currentCharacter: 
		0: 
			var new_texture = load("res://images/snowTiger_backgroundClouds.png") as Texture2D
			$BackgroundImage.texture = new_texture
		1: 
			var new_texture = load("res://images/panda_backgroundClouds.png") as Texture2D
			$BackgroundImage.texture = new_texture
		2: 
			var new_texture = load("res://images/bear_backgroundClouds.png") as Texture2D
			$BackgroundImage.texture = new_texture
		3: 
			var new_texture = load("res://images/bunny_backgroundClouds.png") as Texture2D
			$BackgroundImage.texture = new_texture
		4: 
			var new_texture = load("res://images/pig_backgroundClouds.png") as Texture2D
			$BackgroundImage.texture = new_texture
	
func checkCharacterUnlock(currentCharacter): 
	var isCharacterUnlocked = false
	#$StartGame.visible = false
	print(str(currentCharacter))
	if savedData == "": 
		#$DebugLabel.text = $DebugLabel.text + "sd not loaded"
		print("saved data not loaded yet")
		pass
	else: 
		print("saved character data is available")
		#$DebugLabel.text = $DebugLabel.text + "sd loaded"
		isCharacterUnlocked = bool(savedData["playerUnlocks"][currentCharacter])
		#$DebugLabel.text = $DebugLabel.text + str(isCharacterUnlocked)
	if isCharacterUnlocked == false: 
		$LockIcon.visible = true
		$UnlockButton.visible = true
		$StartGame.visible = false
	else: 
		$LockIcon.visible = false
		$UnlockButton.visible = false
		$StartGame.visible = true
	$CharacterImage.texture = load(characters[currentCharacter])
	
func _on_left_button_pressed():
	currentCharacter = (currentCharacter - 1) % 5
	if soundOn:
		$LeftClick.play()
	updateCharacter()

func _on_right_button_pressed(): 
	currentCharacter = (currentCharacter + 1) % 5
	if soundOn: 
		$RightClick.play()
	updateCharacter()


func _on_google_sign_in_pressed() -> void:
	print("attempting manual sign in with google")
	#$TitleText.text = $TitleText.text + " Manual sign in attempted"
	if GodotPlayGameServices.android_plugin: 
		GodotPlayGameServices.android_plugin.signIn()
	#$TitleText.text = $TitleText.text + " returned"
		

func isSignedInListener(status): 
	print(status)
	#$TitleText.text = "logged in: " + status

func _on_achievements_pressed() -> void:
	if AchievementsClient: 
		#$TitleText.text = "Achievements client found" 
		AchievementsClient.load_achievements(true)
	else:
		pass 
		#$TitleText.text = "Achievements client not found"


func _on_sound_toggle_pressed() -> void:
	print("sound toggled")
	if soundOn: 
		soundOn = false
		$SoundToggle.texture_normal = load("res://images/audioMuted.png")
		$MenuMusic.stop()
	else: 
		soundOn = true
		$SoundToggle.texture_normal = load("res://images/audioOn.png")
		$MenuMusic.play()
	
func _on_menu_music_finished() -> void:
	$MenuMusic.play()


func _on_unlock_button_pressed() -> void:
	print("unlocking a new character")
	match currentCharacter: 
		-1: 
			currentCharacter = 4
		-2: 
			currentCharacter = 3
		-3: 
			currentCharacter = 2
		-4: 
			currentCharacter = 1
	#$DebugLabel.text = $DebugLabel.text + "unl new char"
	if int(savedData["coins"]) >= 300: 
		#$DebugLabel.text = $DebugLabel.text + " unlocked"
		var newCoins = int(savedData["coins"]) - 300
		var playerUnlocks = savedData["playerUnlocks"]
		playerUnlocks[currentCharacter] = true
		var saveData = {"coins": newCoins, "playerUnlocks": playerUnlocks}
		var jsonSaveData = JSON.stringify(saveData)
		savedData = saveData
		updateCoins(newCoins)
		AchievementsClient.unlock_achievement("CgkIuuKhlf8BEAIQCg")
		SnapshotsClient.save_game("playerData", "player data for Animal Dash", jsonSaveData.to_utf8_buffer())
		skipUpdateCharacter = false
		$UnlockButton.visible = false
		$LockIcon.visible = false
		$StartGame.visible = true
		match currentCharacter: 
			1: 
				#panda
				AchievementsClient.unlock_achievement("CgkIuuKhlf8BEAIQCw")
			2: 
				#bear
				AchievementsClient.unlock_achievement("CgkIuuKhlf8BEAIQDA")
			3: 
				#bunny
				AchievementsClient.unlock_achievement("CgkIuuKhlf8BEAIQDQ")
			4: 
				#pig
				AchievementsClient.unlock_achievement("CgkIuuKhlf8BEAIQDg")
	else: 
		pass
		#$DebugLabel.text = $DebugLabel.text + " ins. funds"
