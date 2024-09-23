extends Node
signal hit
signal characterSelect
signal gameOver
var characters = ["res://images/snowTiger_stand.png","res://images/panda_stand_base.png"]
var currentCharacter = 0

@export var game_scene: PackedScene
@export var menu_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	updateCharacter()
	if not GodotPlayGameServices.android_plugin: 
		print("play game services not found")
	else: 
		print("google sign in available")
	var timer = Timer.new()
	timer.wait_time = 2.0  # 2 seconds delay
	timer.one_shot = false
	add_child(timer)
	timer.start()
	await timer.timeout
	check_plugin()
		
func _process(_delta):
	pass
	
func check_plugin(): 
	if GodotPlayGameServices.android_plugin:
		var play_services = Engine.get_singleton("GodotPlayGameServices")
		play_services.some_function()  # Replace with the actual function you're calling
	else:
		print("GodotPlayGameServices plugin not available")
	
func _on_button_pressed():
	$CharacterImage.visible = false
	$StartGame.visible = false
	$LeftButton.visible = false
	$RightButton.visible = false
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
	var menuElements = [$CharacterImage, $StartGame, $LeftButton, $RightButton]
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
