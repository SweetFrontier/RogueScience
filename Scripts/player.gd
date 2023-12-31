class_name Player
extends CharacterBody2D

@export var speed = 300.0
@export var time_to_rotate_slope = 0.5 # Adjust this for slope rotation
@export var falling_rotation_speed = 5.0  # Adjust this for falling rotation
@export var starting_direction = Vector2.RIGHT

# Permanent node children
@export var AnimatedSprite : AnimatedSprite2D
@export var PlayerCollision : CollisionPolygon2D
@export var CrawlSounds : AudioStreamPlayer2D
@export var HitSounds : AudioStreamPlayer2D
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
# Store the current movement direction.
var current_direction = Vector2.RIGHT

var being_controlled = false;
var movement_overrider
var starting_position

#last_y_velocity for how loud to play the hit sound
var last_y_velocity

func _ready():
	starting_position = global_position
	reset()

func reset():
	velocity = Vector2(0,0)
	global_position = starting_position
	current_direction = starting_direction
	AnimatedSprite.rotation = 0.0
	if current_direction == Vector2.RIGHT:
		AnimatedSprite.flip_h = false
		PlayerCollision.scale.x = abs(PlayerCollision.scale.x)
		AnimatedSprite.offset.x = 4
	if current_direction == Vector2.LEFT:
		AnimatedSprite.flip_h = true
		PlayerCollision.scale.x = -1 * abs(PlayerCollision.scale.x)
		AnimatedSprite.offset.x = -4
	free_movement()

func _physics_process(delta):
	if being_controlled:
		return
	#rotate the player
	if is_on_floor():
		rotate_player_on_slope(delta)
		
		#check if crashing, and if so, play sound
		if (last_y_velocity > 0):
			CrawlSounds.play()
			# play the louder one if fall from high up
			if (last_y_velocity > 600):
				HitSounds.stream = load("res://Sounds/hitgroundfromhigh.ogg")
			else:
				HitSounds.stream = load("res://Sounds/hitsomething.ogg")
			last_y_velocity = 0
			HitSounds.play()
	else:
		rotate_player_on_arc(delta)
		
	if not is_on_floor():
		# Add the gravity.
		velocity.y += gravity * delta
		last_y_velocity = velocity.y
		# Get rid of sound
		CrawlSounds.stop()
	
	# Check if there's a wall in the current direction.
	if is_on_wall():
		current_direction = -current_direction
		AnimatedSprite.flip_h = !AnimatedSprite.flip_h
		PlayerCollision.scale.x *= -1
		AnimatedSprite.offset.x += 8*PlayerCollision.scale.x
		#play the sound
		HitSounds.stream = load("res://Sounds/hitsomething.ogg")
		HitSounds.play()
		
	# Move in the current direction.
	velocity.x = current_direction.x * speed
	move_and_slide()

# Function to rotate the player in the air
func rotate_player_on_arc(delta):
	if being_controlled:
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

func movement_overwritten(_movement_overrider):
	being_controlled = true
	movement_overrider = _movement_overrider
	
func free_movement():
	being_controlled = false
	movement_overrider = null

func set_body_pos(pos):
	global_position = pos
