extends Area2D

@export var speed = 400 #(pixels/sec)
var screen_size
var isJumping = false
var isGravity = false
var previousVelocity

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity
	if previousVelocity: 
		velocity = previousVelocity
	else: 
		velocity = Vector2.ZERO
		
	$PlayerSprite.play()
	
	if Input.is_action_just_pressed("jump") || isJumping:
		velocity.y -= 1
		velocity = velocity.normalized() * speed
		previousVelocity = velocity
		isJumping = true
		$PlayerSprite.animation = "Jump"
	elif isGravity: 
		velocity = Vector2.ZERO
		velocity.y += 1
		velocity = velocity.normalized() * speed
		if position.y >= 400: 
			isGravity = false
			velocity = Vector2.ZERO
		previousVelocity = velocity
	else:
		velocity = Vector2.ZERO
		previousVelocity = velocity
		isJumping = false
		$PlayerSprite.animation = "Run"
		
	if position.y >= 600: 
		isGravity = false
		velocity = Vector2.ZERO
	
	position += velocity*delta
	position = position.clamp(Vector2.ZERO, screen_size)



func _on_player_sprite_animation_finished(): 
	pass


func _on_player_sprite_animation_looped():
	if $PlayerSprite.animation == "Jump": 
		isGravity = true
		isJumping = false
		$PlayerSprite.animation = "Fall"
