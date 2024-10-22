extends Node
signal hit
signal characterSelect
signal gameOver

var characters = ["res://images/snowTiger_stand.png","res://images/panda_stand_base.png"]
var currentCharacter = 0

@export var game_scene: PackedScene
@export var menu_scene: PackedScene
@export var achievements_scene: PackedScene

var _sign_in_retries := 1

# Called when the node enters the scene tree for the first time.
func _ready():
	AchievementsClient.achievements_loaded.connect(
		func achievementsLoaded(achievements: Array[AchievementsClient.Achievement]):
			$TitleText.text = $TitleText.text + " inside loaded callback "; 
			AchievementsClient.show_achievements()
	)
	if SignInClient == null or GodotPlayGameServices == null: 
		$TitleText.text = "SignInClient is null"
	SignInClient.user_authenticated.connect(func(is_authenticated: bool):
		if not is_authenticated:
			SignInClient.sign_in()
		else: 
			$TitleText.text = "User has been authenticated"
	)
	updateCharacter()
	if not GodotPlayGameServices.android_plugin: 
		print("play game services not found")
		$TitleText.text = $TitleText.text + "Play game services not found"
	else: 
		print("google sign in available")
		$TitleText.text = $TitleText.text + "Play game services found" 
		
func _process(_delta):
	pass
	
func _on_button_pressed():
	$CharacterImage.visible = false
	$StartGame.visible = false
	$LeftButton.visible = false
	$RightButton.visible = false
	$GoogleSignIn.visible = false
	$TitleText.visible = false
	#remove_child($CharacterImage)
	#remove_child($StartGame)
	#remove_child($LeftButton)
	#remove_child($RightButton)
	var game = game_scene.instantiate()
	add_child(game)
	game.get_node("Player").call("_on_character_select", characters[currentCharacter].replace("res://images/","").replace("_stand.png","").replace("_stand_base.png","")); 
	#emit_signal("characterSelect")
	game.connect("gameOver", _on_game_finished)
	
func _on_game_finished(): 
	print("on game finished")
	redoMainMenu()
	
func redoMainMenu(): 
	print("recreating main menu")
	var menuElements = [$CharacterImage, $StartGame, $LeftButton, $RightButton, $GoogleSignIn, $TitleText, $Achievements]
	for element in menuElements: 
		print("making element visible")
		element.visible = true
	_ready()

func updateCharacter(): 
	print('updating character')
	$CharacterImage.texture = load(characters[currentCharacter])
	
func _on_left_button_pressed():
	currentCharacter = (currentCharacter - 1) % 2
	updateCharacter()

func _on_right_button_pressed(): 
	currentCharacter = (currentCharacter + 1) % 2
	updateCharacter()


func _on_google_sign_in_pressed() -> void:
	print("attempting manual sign in with google")
	$TitleText.text = $TitleText.text + " Manual sign in attempted"
	if GodotPlayGameServices.android_plugin: 
		GodotPlayGameServices.android_plugin.signIn()
	$TitleText.text = $TitleText.text + " returned"
		

func isSignedInListener(status): 
	print(status)
	$TitleText.text = "logged in: " + status

func _on_achievements_pressed() -> void:
	if AchievementsClient: 
		$TitleText.text = "Achievements client found" 
		AchievementsClient.load_achievements(true)
	else: 
		$TitleText.text = "Achievements client not found"
