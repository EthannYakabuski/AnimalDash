extends Area2D
signal hit

@export var speed = 400 #(pixels/sec)
var screen_size
var isJumping = false
var isGravity = false
var jumped = 0
var previousVelocity

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity
	var gravity = 40000
	if previousVelocity: 
		velocity = previousVelocity
	else: 
		velocity = Vector2.ZERO
		
	$PlayerSprite.play()
	
	if Input.is_action_just_pressed("jump") && jumped < 2 && isJumping: 
		isJumping = true
		isGravity = true
		velocity = Vector2.ZERO
		jumped = jumped + 1
		$PlayerSprite.animation = "Run"
		$PlayerSprite.animation = "Jump"
	
	if (Input.is_action_just_pressed("jump") && jumped < 2 || isJumping):
		velocity = Vector2.ZERO
		velocity.y -= 500
		#velocity = velocity.normalized() * speed
		previousVelocity = velocity
		isJumping = true
		if(Input.is_action_just_pressed("jump")): 
			jumped = jumped + 1
		$PlayerSprite.animation = "Jump"
	elif isGravity: 
		velocity = Vector2.ZERO
		velocity.y += 1 + gravity * delta
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


func _on_body_entered(body):
	hide() # Player disappears after being hit.
	hit.emit()
	print("body entered")
	# Must be deferred as we can't change physics properties on a physics callback.
	# $CollisionShape2D.set_deferred("disabled", true)
