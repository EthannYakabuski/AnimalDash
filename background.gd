extends Node2D

@export var coin_scene: PackedScene
@export var spike_scene: PackedScene
@export var player_scene: PackedScene
@export var food_scene: PackedScene
var score
var spike
var coinArray = []
var foodArray = []

signal collect
signal hit
signal eat
signal characterSelect

var spike_patterns = [
	[1, 1, 1, 1, 1],       
	[3, 3, 1, 3, 4],  
	[3, 0.5, 0.5, 1, 3], 
	[0.5, 0.5, 3, 0.5, 3],  
	[0.25, 0.25, 0.25, 3, 3],
	[0.5, 0.5, 3, 1, 1],  
	[0.5, 0.5, 0.5, 3, 1] 
]
var spikePointer = 0

func new_game(): 
	score = 0
	$Player.position = $StartPosition.position
	
	#var background_layer = $Parallax_Background/parallax_lay_one
	#var backgroundSprite = $Parallax_Background/parallax_lay_one/layone_sprite
	
	#var foreground_layer = $Parallax_Background/parallax_lay_two
	#var foregroundSprite = $Parallax_Background/parallax_lay_two/laytwo_sprite

	$StartTimer.start()
	
func game_over(): 
	$SpikeTimer.stop()
	$CoinTimer.stop()
	$FoodTimer.stop()
	
# Called when the node enters the scene tree for the first time.
func _ready():
	#var screen_size = get_viewport_rect().size
	$Player.connect("hit", _on_hit)
	$Player.connect("collect", _on_collect)
	$Player.connect("eat", _on_eat)
	self.connect("characterSelect", _on_characterSelect)
	new_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var background_background = $Parallax_Background
	background_background.scroll_base_offset -= Vector2(5,0) * delta
	$EnergyBar.value = $Player.energy
	if $Player.energy < 0: 
		$Player.hide()
		game_over()

func _on_start_timer_timeout():
	$SpikeTimer.start()
	$CoinTimer.start()
	$FoodTimer.start()

func _on_spike_timer_timeout():
	print("spike spawned")
	spikePointer = spikePointer + 1
	spike = spike_scene.instantiate()
	spike.add_to_group("Spike")
	
	var spike_loc = $SpikeSpawn/SpikeSpawnLocation
	spike_loc.progress_ratio = randf()
	
	var velocity = Vector2(-300, 0.0)
	var direction = 2*PI
	spike.rotation = direction
	spike.linear_velocity = velocity.rotated(direction)
	add_child(spike)
	var newWaitTime = randf_range(1.0,3.0)
	$SpikeTimer.wait_time = newWaitTime
	$SpikeTimer.start()


func _on_coin_timer_timeout():
	print("coin spawned")
	var coin = coin_scene.instantiate()
	coin.add_to_group("Coin")
	coinArray.push_back(coin)
	
	var coin_loc = $CoinPath/CoinPathFollow
	coin_loc.progress_ratio = randf()
	
	var velocity = Vector2(-350, 0.0)
	var direction = 2*PI
	coin.rotation = direction
	coin.linear_velocity = velocity.rotated(direction)
	add_child(coin)


func _on_collect():
	print("coin collected in main")
	$Player.energy = $Player.energy + 50
	for coin in coinArray: 
		remove_child(coin)
		
func _on_eat(): 
	print("eat in main")
	$Player.energy = $Player.energy + 400
	for food in foodArray: 
		remove_child(food)
		
func _on_characterSelect(characterSelected): 
	print("character selected")
	print(characterSelected)

func _on_hit():
	print("spike hit in main")


func _on_food_timer_timeout():
	print("food spawned")
	var food = food_scene.instantiate(); 
	food.add_to_group("Food"); 
	foodArray.push_back(food);
	
	var food_loc = $Foodpath/FoodPathFollow
	food_loc.progress_ratio = randf()
	
	var velocity = Vector2(-150,0.0)
	var direction = 2*PI
	food.rotation = direction
	food.linear_velocity = velocity.rotated(direction)
	add_child(food)
	var newWaitTime = randf_range(10.0,15.0)
	$FoodTimer.wait_time = newWaitTime
	$FoodTimer.start()
	
	
	
	
