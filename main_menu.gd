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

@export var game_scene: PackedScene
@export var menu_scene: PackedScene
@export var achievements_scene: PackedScene

var _sign_in_retries := 1

# Called when the node enters the scene tree for the first time.
func _ready():
	SnapshotsClient.game_loaded.connect(
		func(snapshot: SnapshotsClient.Snapshot):
			if !snapshot:
				$DebugLabel.text = $DebugLabel.text + " snap not found" 
				print("snap shot not found")
				SnapshotsClient.save_game("playerData", "player data for Animal Dash", str(0).to_utf8_buffer())
			$DebugLabel.text = $DebugLabel.text + "here1"
			currentData = snapshot.content.get_string_from_utf8()
			$DebugLabel.text = $DebugLabel.text + "currentData: " + currentData
			$CoinsLabel.text = currentData
	)
	
	SnapshotsClient.conflict_emitted.connect(
		func():
			$DebugLabel.text = $DebugLabel.text + "snapshot conflict"
	)
	AchievementsClient.achievements_loaded.connect(
		func achievementsLoaded(achievements: Array[AchievementsClient.Achievement]):
			#$TitleText.text = $TitleText.text + " inside loaded callback "; 
			AchievementsClient.show_achievements()
	)
	SnapshotsClient.game_saved.connect(
		func(is_saved: bool, save_data_name: String, save_data_description: String):
			if is_saved: 
				$DebugLabel.text = $DebugLabel.text + " game saved"
			else: 
				$DebugLabel.text = $DebugLabel.text + " unable to save game"
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
			$DebugLabel.text = $DebugLabel.text + "trying to load data "
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
	
func _on_game_finished(): 
	if soundOn: 
		$HitSound.play()
	print("on game finished")
	$DebugLabel.text = $DebugLabel.text + "here2"
	
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
