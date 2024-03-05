extends Node2D
class_name SPLAT


# Called when the node enters the scene tree for the first time.
func _ready():
	var collisionShape = CircleShape2D.new()
	collisionShape.radius = 32
	$Area2D/CollisionShape2D.set_deferred("shape", collisionShape)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
