extends RigidBody2D
signal hit

var passed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$SpikeImage.play("Base")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
