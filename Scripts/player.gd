class_name Player
extends CharacterBody2D

@export var speed = 300.0
@export var jump_velocity = -400.0
@export var time_to_rotate_slope = 0.5 # Adjust this for slope rotation
@export var falling_rotation_speed = 5.0  # Adjust this for falling rotation
# Permanent node children
@export var AnimatedSprite : AnimatedSprite2D
@export var PlayerCollision : CollisionPolygon2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
# Store the current movement direction.
var current_direction = Vector2.RIGHT
# jumping on trampoline flag
var moving_to_tramp = false
var tramp_jumping = false
var trampoline_initial_position: Vector2  # Initial position before interpolation
var trampoline_target_position: Vector2  # Store the target position of the trampoline jump
var trampoline_jump_force: Vector2  # Store the desired jump force
var trampoline_moving_speed = 18


func _physics_process(delta):
	#rotate the player
	if is_on_floor():
		rotate_player_on_slope(delta)
	else:
		rotate_player_on_arc(delta)
		
	if !move_toward_trampoline(delta):
		if is_on_floor():
			tramp_jumping = false
		elif not is_on_floor():
			# Add the gravity.
			velocity.y += gravity * delta
		# Check if there's a wall in the current direction.
		if is_on_wall():
			current_direction = -current_direction
			AnimatedSprite.flip_h = !AnimatedSprite.flip_h
			PlayerCollision.scale.x *= -1
		if !tramp_jumping:
			# Move in the current direction.
			velocity.x = current_direction.x * speed
	move_and_slide()

# Function to rotate the player in the air
func rotate_player_on_arc(delta):
	if moving_to_tramp or tramp_jumping:
		# Calculate the angle between the player's current rotation and the target rotation (0 degrees).
		var target_angle = 0
		var current_angle = AnimatedSprite.rotation
		var angle_diff = target_angle - current_angle
		
		var rotation_speed = angle_diff * falling_rotation_speed
		
		# Rotate the player towards the target angle.
		AnimatedSprite.rotation += rotation_speed * delta
	elif !is_on_floor() and velocity.x !=0:
		var arc_angle = atan2(velocity.y, velocity.x)  # Calculate the angle of the arc
		arc_angle += 0.0 if current_direction == Vector2.RIGHT else PI
		AnimatedSprite.rotation = lerp_angle(AnimatedSprite.rotation, arc_angle, falling_rotation_speed * delta)

# Function to rotate the player on slopes.
func rotate_player_on_slope(delta):
	if is_on_floor() and velocity.x != 0:
		var slope_angle = Vector2.UP.angle_to(get_floor_normal())
		AnimatedSprite.rotation += (slope_angle - AnimatedSprite.rotation) / time_to_rotate_slope * delta

func touched_trampoline(tramp_force, tramp_pos):
	if is_on_floor():
		moving_to_tramp = true
		# Set the trampoline's target position and jump force
		trampoline_target_position = tramp_pos
		trampoline_jump_force = Vector2(0, tramp_force)
		trampoline_initial_position = position
	else:
		jump_on_tramp(Vector2(0, tramp_force))

func move_toward_trampoline(delta):
	if moving_to_tramp:
		# Calculate the interpolation ratio based on elapsed time.
		var interpolation_ratio = clamp(delta * trampoline_moving_speed, 0.0, 1.0)
		# Interpolate the position towards the trampoline's position.
		position = lerp(position, trampoline_target_position, interpolation_ratio)
		# Check if the interpolation is complete.
		if position.distance_to(trampoline_target_position) < 1.0:
			position = trampoline_target_position
			moving_to_tramp = false
			jump_on_tramp(trampoline_jump_force)
		return true
	return false

func jump_on_tramp(_trampoline_jump_force):
	tramp_jumping = true
	velocity = _trampoline_jump_force
