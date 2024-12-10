extends RigidBody2D

signal foodcoincollision

var passed = false
var collected = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$FoodSprite.play("Standard")
 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func _on_body_entered(body):
	if body.is_in_group("Coin"): 
		print("food collided with coin")
		#collect.emit()
		emit_signal("foodcoincollision")
