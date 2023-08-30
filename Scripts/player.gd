extends CharacterBody2D


@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0
# Permanent node children
@export var AnimatedSprite : AnimatedSprite2D
@export var PlayerCollision : CollisionPolygon2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Store the current movement direction.
var current_direction = Vector2.RIGHT

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Check if there's a wall in the current direction.
	if is_on_wall():
		current_direction = -current_direction
		AnimatedSprite.flip_h = !AnimatedSprite.flip_h

	# Move in the current direction.
	velocity.x = current_direction.x * SPEED

	move_and_slide()
