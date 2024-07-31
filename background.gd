extends Node2D

@export var coin_scene: PackedScene
@export var spike_scene: PackedScene
@export var player_scene: PackedScene
@export var food_scene: PackedScene
var score
var spike
var spikeArray = []
var coinArray = []
var foodArray = []
var points = 0

signal collect
signal hit
signal eat
signal characterSelect
signal foodcoincollision

var spike_patterns = [
	[1, 1, 1, 0.5, 0.5],       
	[3, 3, 1, 1, 2],  
	[3, 0.5, 0.5, 1, 3], 
	[0.5, 0.5, 3, 3, 3],  
	[0.25, 0.25, 1, 2, 2],
	[0.5, 0.5, 3, 1, 1],  
	[0.5, 0.5, 0.5, 3, 1] 
]
var spikePointer = 0
var currentPattern = 0
var resolveSpikePattern = false

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
	#self.connect("foodcoincollision", _on_foodcoincollision)
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
	checkSpikePoints()
	
func checkSpikePoints():
	for spikeItem in spikeArray:
		#print(spikeItem.position.x)
		if spikeItem.position.x < -580 and not spikeItem.passed: 
			print("spike point")
			spikeItem.passed = true
	
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
	
	var velocity = Vector2(-400, 0.0)
	var direction = 2*PI
	spike.rotation = direction
	spike.linear_velocity = velocity.rotated(direction)
	spikeArray.push_back(spike)
	add_child(spike)
	var newWaitTime = randf_range(1.0,3.0)
	
	if(!resolveSpikePattern): 
		var randomRoll = randi() % 3 #33% chance to select and start a pattern of spikes
		if(randomRoll == 0): 
			print("pattern started")
			currentPattern = randi() % 7
			spikePointer = 0
			resolveSpikePattern = true
			
	if(resolveSpikePattern): 
		if(spikePointer == 4): 
			resolveSpikePattern = false
			currentPattern = 0
		$SpikeTimer.wait_time = spike_patterns[currentPattern][spikePointer]
		spikePointer = spikePointer + 1
	else: 
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
	coin.collision_layer = 2
	coin.collision_mask = 0b00000101
	add_child(coin)


func _on_collect():
	print("coin collected in main")
	points = points + 10
	$Player.energy = $Player.energy + 50
	for coin in coinArray: 
		if coin.position.x < 0:
			remove_child(coin)
	coinArray = []
		
func _on_eat(): 
	print("eat in main")
	points = points + 5
	$Player.energy = $Player.energy + 600
	for food in foodArray: 
		remove_child(food)
		
func _on_characterSelect(characterSelected): 
	print("character selected")
	print(characterSelected)
	
func _on_foodcoincollision(): 
	print("food coin collision in main")

func _on_hit():
	print("spike hit in main")

func _on_food_Entered(): 
	print("food entered in main")
	
func _on_food_timer_timeout():
	print("food spawned")	
	var food = food_scene.instantiate(); 
	food.add_to_group("Food"); 
	foodArray.push_back(food);
	
	var food_loc = $Foodpath/FoodPathFollow
	food_loc.progress_ratio = randf()
	
	food.connect("body_entered", _on_food_Entered)
	
	var velocity = Vector2(-150,0.0)
	var direction = 2*PI
	food.rotation = direction
	food.linear_velocity = velocity.rotated(direction)
	food.collision_layer = 2
	food.collision_mask = 0b00000101
	add_child(food)
	var newWaitTime = randf_range(10.0,15.0)
	$FoodTimer.wait_time = newWaitTime
	$FoodTimer.start()
	
	
	
	
