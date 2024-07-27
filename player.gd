extends Area2D

@export var speed = 400 #(pixels/sec)
var screen_size
var isJumping = false
var isGravity = false
var jumped = 0
var previousVelocity
var animationHandle
@export var energy = 1000;

var characters = ["snowTiger", "panda"]
var panda_falling_frames = [];
var snowTiger_falling_frames = [];
var chosenCharacter = "snowTiger"

signal collect
signal hit
signal eat
signal characterSelect

func _on_character_select(characterSelected): 
	print("character selected in Player " + characterSelected)
	chosenCharacter = characterSelected
	self.call("_ready")

# Called when the node enters the scene tree for the first time.
func _ready():
	#self.connect("characterSelect", _on_character_select)
	screen_size = get_viewport_rect().size
	loadCharacterFramesBasedOnChosenCharacter(chosenCharacter)
	
func loadCharacterFramesBasedOnChosenCharacter(character_name): 
	print(character_name + "has been chosen")
	var dynamicallyCreatedAnimatedSprite = createCharacterFrames(character_name)
	self.add_child(dynamicallyCreatedAnimatedSprite)
	animationHandle = dynamicallyCreatedAnimatedSprite

func createCharacterFrames(character_name):
	var fallFrames = [character_name+"_jump_three.png"]
	var jumpFrames = [character_name+"_stand.png",character_name+"_jump_one.png",character_name+"_jump_two.png",character_name+"_jump_three.png"]
	var runFrames = [character_name+"_stand.png",character_name+"_jump_one.png"]
	var animatedSprite = AnimatedSprite2D.new()
	var frames = SpriteFrames.new()
	frames.add_animation("Fall")
	for frame_name in fallFrames:
		var texture = load("res://images/"+frame_name) as Texture
		frames.add_frame("Fall", texture)
	frames.add_animation("Jump")
	for frame_name in jumpFrames: 
		var texture = load("res://images/"+frame_name) as Texture
		frames.add_frame("Jump", texture)
	frames.add_animation("Run")
	for frame_name in runFrames: 
		var texture = load("res://images/"+frame_name) as Texture
		frames.add_frame("Run", texture)
	animatedSprite.sprite_frames = frames
	animatedSprite.scale.x = 0.5
	animatedSprite.scale.y = 0.5
	animatedSprite.connect("animation_finished", on_player_sprite_animation_finished)
	animatedSprite.connect("animation_looped", on_player_sprite_animation_looped)
	return animatedSprite
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity
	gravity = 40000
	if previousVelocity: 
		velocity = previousVelocity
	else: 
		velocity = Vector2.ZERO
		
	#animationHandle.play()
	animationHandle.play()
	
	if Input.is_action_just_pressed("jump") && jumped < 2 && isJumping: 
		isJumping = true
		isGravity = true
		velocity = Vector2.ZERO
		jumped = jumped + 1
		animationHandle.animation = "Run"
		animationHandle.animation = "Jump"
	
	if (Input.is_action_just_pressed("jump") && jumped < 2 || isJumping):
		velocity = Vector2.ZERO
		velocity.y -= 400
		energy = energy - 2.5
		#velocity = velocity.normalized() * speed
		previousVelocity = velocity
		isJumping = true
		if(Input.is_action_just_pressed("jump")): 
			jumped = jumped + 1
		animationHandle.animation = "Jump"
	elif isGravity: 
		velocity = Vector2.ZERO
		velocity.y += 1 + gravity * 1.5 * delta
		#velocity = velocity.normalized() * speed
		if position.y >= 400: 
			isGravity = false
			velocity = Vector2.ZERO
		previousVelocity = velocity
	else:
		velocity = Vector2.ZERO
		previousVelocity = velocity
		isJumping = false
		jumped = 0
		animationHandle.animation = "Run"
		
	if position.y >= 600: 
		isGravity = false
		velocity = Vector2.ZERO
		
	if animationHandle.animation == "Run": 
		energy = energy + 1
		if energy > 1000: 
			energy = 1000
	
	position += velocity*delta
	position = position.clamp(Vector2.ZERO, screen_size)


func on_player_sprite_animation_finished(): 
	print("animation finished")


func on_player_sprite_animation_looped():
	if animationHandle.animation == "Jump": 
		isGravity = true
		isJumping = false
		animationHandle.animation = "Fall"

func _on_body_entered(body):
	if body.is_in_group("Coin"): 
		print("coin collected")
		#collect.emit()
		emit_signal("collect")
	elif body.is_in_group("Spike"): 
		print("spike hit")
		hide()
		#hit.emit()
		emit_signal("hit")
	elif body.is_in_group("Food"): 
		print("food collected"); 
		emit_signal("eat")
