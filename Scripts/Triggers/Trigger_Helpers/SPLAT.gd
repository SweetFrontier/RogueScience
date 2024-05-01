extends Node2D
class_name SPLAT


# Called when the node enters the scene tree for the first time.
func _ready():
	var collisionShape = CircleShape2D.new()
	collisionShape.radius = 32
	$Area2D/CollisionShape2D.set_deferred("shape", collisionShape)


func _on_area_2d_body_entered(collider):
	if collider is rigidPlayer or collider is movingObject or collider is Bullet or collider is boss:
		collider.inSoda += 1


func _on_area_2d_body_exited(collider):
	if collider is rigidPlayer or collider is movingObject or collider is Bullet or collider is boss:
		collider.inSoda -= 1
