extends Node

@export var game_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	remove_child($CharacterImage)
	remove_child($StartGame)
	var game = game_scene.instantiate()
	add_child(game)
