extends CharacterBody2D
class_name boss

@export var speed = 6000.0
@export var stickyMultiplier = 0.5

var current_direction = Vector2.RIGHT

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if is_on_wall():
		current_direction.x = -current_direction.x

	velocity.x = current_direction.x * speed * delta
	move_and_slide()
