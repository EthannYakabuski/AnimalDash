extends Node2D

@export var coin_scene: PackedScene
@export var spike_scene: PackedScene
@export var player_scene: PackedScene
@export var food_scene: PackedScene
@export var plus_scene: PackedScene
var score
var spike
var spikeArray = []
var coinArray = []
var foodArray = []
var points = 0
var coinsCollected = 0
var justGettingStarted = false
var journeyBegun = false

var sound_coinCollect
var sound_foodCollect
var sound_jump
var sound_doubleJump
var sound_hit
var sound_land

var lastFlashFrame
var isFlashing = false

var spikesCleared = 0
var isInAir = false

signal collect
signal hit
signal eat
signal characterSelect
signal foodcoincollision
signal gameOver

var spike_patterns = [
	[1, 1, 1, 3, 3],       
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
var gamePaused = false

var soundOn = true

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
	for child in get_children():
		if child is Timer:
			print("nothing")
		else: 
			child.queue_free()
	gamePaused = true
	emit_signal("gameOver")
	
# Called when the node enters the scene tree for the first time.
func _ready():
	$Score.text = str(0)
	#var screen_size = get_viewport_rect().size
	$Player.connect("hit", _on_hit)
	$Player.connect("collect", _on_collect)
	$Player.connect("eat", _on_eat)
	$Player.connect("jump", _on_jump)
	$Player.connect("doubleJump", _on_doubleJump)
	$Player.connect("land", _on_land)
	#self.connect("foodcoincollision", _on_foodcoincollision)
	self.connect("characterSelect", _on_characterSelect)
	LeaderboardsClient.score_submitted.connect(
		func refresh_score(is_submitted: bool, leaderboard_id: String):
			pass
	)
	sound_coinCollect = $CoinSound
	sound_foodCollect = $EatSound
	sound_jump = $JumpSound
	sound_doubleJump = $DoubleJumpSound
	sound_hit = $HitSound
	sound_land = $LandSound
	new_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(!gamePaused): 
		var background_background = $Parallax_Background
		background_background.scroll_base_offset -= Vector2(5,0) * delta
		$EnergyBar.value = $Player.energy
		if $Player.energy < 350: 
			isFlashing = true
			$EnergyBar.tint_progress = Color(1,0,0)
		else: 
			isFlashing = false
			lastFlashFrame = 0
			$EnergyBar.tint_progress = Color(0.28, 0.86, 0.30)
		if isFlashing: 
			lastFlashFrame = lastFlashFrame + 1
		if lastFlashFrame > 12: 
			lastFlashFrame = 0
			$EnergyBar.tint_progress = Color(1,1,1)
		if $Player.energy < 0: 
			AchievementsClient.unlock_achievement("CgkIuuKhlf8BEAIQBg")
			$Player.hide()
			game_over()
		checkSpikePoints()

func _on_sound_toggled(soundValue): 
	print("sound toggled in game " + str(soundValue))
	soundOn = soundValue
	if soundOn: 
		$BaselineKickin.play()

func checkSpikePoints():
	for spikeItem in spikeArray:
		#print(spikeItem.position.x)
		if spikeItem.position.x < -580 and not spikeItem.passed: 
			print("spike point")
			spikeItem.passed = true
			addPoints(1)
			addIndicator(spikeItem.position)
			
func _on_start_timer_timeout():
	$SpikeTimer.start()
	$CoinTimer.start()
	$FoodTimer.start()

func addPoints(pointsToAdd): 
	points = points + pointsToAdd
	$Score.text = str(points)
	print(points)
	if points >= 25 and not journeyBegun: 
		#$DebugText.text = "Just unlocked journey begun"
		AchievementsClient.unlock_achievement("CgkIuuKhlf8BEAIQAw")
		journeyBegun = true
	if points >= 100 and not justGettingStarted:
		#$DebugText.text = "Just unlocked Just getting started" 
		AchievementsClient.unlock_achievement("CgkIuuKhlf8BEAIQAQ")
		justGettingStarted = true
	if points >= 500: 
		AchievementsClient.unlock_achievement("CgkIuuKhlf8BEAIQBA")
	
func addIndicator(position): 
	print("adding + indicator to the UI")
	var newPlus = plus_scene.instantiate();
	position.x = position.x + 300
	position.y = $Player.position.y - 100
	newPlus.position = position
	newPlus.collision_layer = 2
	newPlus.collision_mask = 0b00000101
	add_child(newPlus)

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
		var randomRoll = randi() % 2 #50% chance to select and start a pattern of spikes
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
	addPoints(3)
	coinsCollected = coinsCollected + 1
	sound_coinCollect.play()
	$Player.energy = $Player.energy + 50
	if coinsCollected >= 25: 
		AchievementsClient.unlock_achievement("CgkIuuKhlf8BEAIQBw"); 
	for coin in coinArray: 
		if coin.position.x < 0:
			remove_child(coin)
	coinArray = []

func _on_land(): 
	print("land in main")
	sound_land.play()

func _on_doubleJump(): 
	print("double jump in main")
	sound_doubleJump.play()	
	
func _on_jump():
	print("on jump in main")
	sound_jump.play()
		
func _on_eat(): 
	print("eat in main")
	addPoints(2)
	sound_foodCollect.play()
	$Player.energy = $Player.energy + 600
	if $Player.energy > 1000: 
		$Player.energy = 1000
	for food in foodArray: 
		remove_child(food)
		
func _on_characterSelect(characterSelected): 
	print("character selected")
	print(characterSelected)
	
func _on_foodcoincollision(): 
	print("food coin collision in main")

func _on_hit():
	print("spike hit in main")
	$HitSound.play()
	if LeaderboardsClient: 
		LeaderboardsClient.submit_score("CgkIuuKhlf8BEAIQAg", int(points))
		LeaderboardsClient.submit_score("CgkIuuKhlf8BEAIQCQ", int(coinsCollected))
	game_over()

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
	var newWaitTime = randf_range(8.0,17.0)
	$FoodTimer.wait_time = newWaitTime
	$FoodTimer.start()
	
func _on_baseline_kickin_finished():
	$BaselineKickin.play()
