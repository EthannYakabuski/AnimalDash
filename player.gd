extends Area2D

@export var speed = 400 #(pixels/sec)
var screen_size
var isJumping = false
var isGravity = false
var jumped = 0
var previousVelocity
@export var energy = 1000;

signal collect
signal hit

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
		energy = energy - 5
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
		
	if $PlayerSprite.animation == "Run": 
		energy = energy + 1
		if energy > 1000: 
			energy = 1000
	
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
	if body.is_in_group("Coin"): 
		print("coin collected")
		collect.emit()
		emit_signal("collect")
	elif body.is_in_group("Spike"): 
		print("spike hit")
		hide()
		hit.emit()
		emit_signal("hit")
