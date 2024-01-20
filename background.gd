extends Node2D

@export var spike_scene: PackedScene
var score
var screen_size

func new_game(): 
	score = 0
	$Player.position = $StartPosition.position
	var background_background = ParallaxBackground.new()
	add_child(background_background)
	
	var background_layer = ParallaxLayer.new()
	background_background.add_child(background_layer)
	var backgroundSprite = Sprite2D.new()
	backgroundSprite.texture = preload("res://images/snowTiger_background.png")
	background_layer.add_child(backgroundSprite)
	background_background.add_child(background_layer)
	
	#$Player.start($StartPosition.position)
	$StartTimer.start()
	
func game_over(): 
	$SpikeTimer.stop()
	
# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	new_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_timer_timeout():
	$SpikeTimer.start()


func _on_spike_timer_timeout():
	pass # spawn a spike/set of spikes on the screen
