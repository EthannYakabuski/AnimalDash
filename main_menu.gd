extends Node
signal hit
signal characterSelect
signal gameOver
signal coinsCollectedSignal

var characters = ["res://images/snowTiger_stand.png","res://images/panda_stand_base.png"]
var currentCharacter = 0

var soundOn = true
var menuMusic
var currentData: String
var savedData = ""

@export var game_scene: PackedScene
@export var menu_scene: PackedScene
@export var achievements_scene: PackedScene

var _sign_in_retries := 1

# Called when the node enters the scene tree for the first time.
func _ready():
	SnapshotsClient.game_loaded.connect(
		func(snapshot: SnapshotsClient.Snapshot):
			if !snapshot:
				#$DebugLabel.text = $DebugLabel.text + " snap not found" 
				print("snap shot not found")
				var saveData = {"coins": 0, "playerUnlocks": [true,false]}
				updateCoins(0)
				var jsonSaveData = JSON.stringify(saveData)
				SnapshotsClient.save_game("playerData", "player data for Animal Dash", jsonSaveData.to_utf8_buffer())
			#$DebugLabel.text = $DebugLabel.text + "here1"
			currentData = snapshot.content.get_string_from_utf8()
			var parsedData = JSON.parse_string(currentData)
			savedData = parsedData
			var currentPlayerCoins = parsedData["coins"]
			updateCharacter()
			#$DebugLabel.text = $DebugLabel.text + "currentData: " + currentData
			$CoinsLabel.text = currentPlayerCoins
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
				updateCharacter()
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
			SnapshotsClient.load_game("playerData", true)
	)
	updateCharacter()
	menuMusic = $MenuMusic
	redoMainMenu() 
	if soundOn: 
		menuMusic.play()
	if not GodotPlayGameServices.android_plugin: 
		print("play game services not found")
		#$TitleText.text = $TitleText.text + "Play game services not found"
	else: 
		print("google sign in available")
		#$TitleText.text = $TitleText.text + "Play game services found"
		
func _process(_delta):
	pass
	
func _on_button_pressed():
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
	#remove_child($CharacterImage)
	#remove_child($StartGame)
	#remove_child($LeftButton)
	#remove_child($RightButton)
	var game = game_scene.instantiate()
	add_child(game)
	game.call("_on_sound_toggled", soundOn)
	game.get_node("Player").call("_on_character_select", characters[currentCharacter].replace("res://images/","").replace("_stand.png","").replace("_stand_base.png","")); 
	#emit_signal("characterSelect")
	game.connect("gameOver", _on_game_finished)
	game.connect("coinsCollectedSignal", _on_coins_collected)
	
func _on_coins_collected(amount): 
	redoMainMenu()
	$CoinsLabel.text = amount
	
func updateCoins(amount): 
	$CoinsLabel.text = amount
	
func _on_game_finished(): 
	if soundOn: 
		$HitSound.play()
	print("on game finished")
	#$DebugLabel.text = $DebugLabel.text + "here2"
	
func redoMainMenu(): 
	print("recreating main menu")
	if soundOn: 
		$MenuMusic.play()
	var menuElements = [$CharacterImage, $StartGame, $LeftButton, $RightButton, $GoogleSignIn, $TitleText, $Achievements, $SoundToggle, $CoinLabelSprite, $CoinsLabel]
	for element in menuElements: 
		print("making element visible")
		element.visible = true

func updateCharacter(): 
	print('updating character')
	$DebugLabel.text = $DebugLabel.text + " " + str(currentCharacter)
	checkCharacterUnlock(currentCharacter)
	
func checkCharacterUnlock(currentCharacter): 
	var isCharacterUnlocked = false
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
	currentCharacter = (currentCharacter - 1) % 2
	if soundOn: 
		$LeftClick.play()
	updateCharacter()

func _on_right_button_pressed(): 
	currentCharacter = (currentCharacter + 1) % 2
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
	$DebugLabel.text = $DebugLabel.text + "unl new char"
	if int(savedData["coins"]) >= 300: 
		$DebugLabel.text = $DebugLabel.text + " unlocked"
		var newCoins = int(savedData["coins"]) - 300
		var playerUnlocks = savedData["playerUnlocks"]
		playerUnlocks[currentCharacter] = true
		var saveData = {"coins": newCoins, "playerUnlocks": playerUnlocks}
		var jsonSaveData = JSON.stringify(saveData)
		savedData = saveData
		updateCoins(newCoins)
		SnapshotsClient.save_game("playerData", "player data for Animal Dash", jsonSaveData.to_utf8_buffer())
	else: 
		$DebugLabel.text = $DebugLabel.text + " ins. funds"
