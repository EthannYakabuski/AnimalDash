extends Node2D

@export var spike_scene: PackedScene
var score
var screen_size

func new_game(): 
	score = 0
	$Player.position = $StartPosition.position
	
	var background_layer = $Parallax_Background/parallax_lay_one
	var backgroundSprite = $Parallax_Background/parallax_lay_one/layone_sprite
	
	var foreground_layer = $Parallax_Background/parallax_lay_two
	var foregroundSprite = $Parallax_Background/parallax_lay_two/laytwo_sprite

	$StartTimer.start()
	
func game_over(): 
	$SpikeTimer.stop()
	
# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	new_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var background_background = $Parallax_Background
	background_background.scroll_base_offset -= Vector2(5,0) * delta


func _on_start_timer_timeout():
	$SpikeTimer.start()


func _on_spike_timer_timeout():
	pass # spawn a spike/set of spikes on the screen
