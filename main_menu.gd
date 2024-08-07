extends Node
signal hit
signal characterSelect
var characters = ["res://images/snowTiger_stand.png","res://images/panda_stand_base.png"]
var currentCharacter = 0

@export var game_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	updateCharacter()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_button_pressed():
	remove_child($CharacterImage)
	remove_child($StartGame)
	remove_child($LeftButton)
	remove_child($RightButton)
	var game = game_scene.instantiate()
	add_child(game)
	game.get_node("Player").call("_on_character_select", characters[currentCharacter].replace("res://images/","").replace("_stand.png","").replace("_stand_base.png","")); 
	#emit_signal("characterSelect")

func updateCharacter(): 
	$CharacterImage.texture = load(characters[currentCharacter])
	
func _on_left_button_pressed():
	currentCharacter = (currentCharacter - 1) % 2
	updateCharacter()

func _on_right_button_pressed(): 
	currentCharacter = (currentCharacter + 1) % 2
	updateCharacter()
