extends RigidBody2D
class_name rigidPlayer

@export var speed = 300.0
@export var time_to_rotate_slope = 0.5 # Adjust this for slope rotation
@export var falling_rotation_speed = 5.0  # Adjust this for falling rotation
@export var starting_direction = Vector2.RIGHT

# Permanent node children
@export var AnimatedSprite : AnimatedSprite2D
@export var PlayerCollision : CollisionPolygon2D
@export var CrawlSounds : AudioStreamPlayer2D
@export var HitSounds : AudioStreamPlayer2D

@export var floorCollisionArea: Area2D
@export var floorCast: RayCast2D
@export var wallCast: RayCast2D

var current_direction = Vector2.RIGHT

var starting_transform
var just_reset = true
var being_controlled = false
var just_started_control = false
var positioning_finished = false
var movement_overrider
var next_pos: Vector2
var once_freed_angular_velocity: float
var once_freed_linear_velocity: Vector2
var controlled_ang_vel: float = 0.0
var controlled_lin_vel: Vector2 = Vector2()
var directPosControl: bool = false
var floorCollisions: int = 0

func _ready():
	starting_transform = get_global_transform()
	reset()

func reset():
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
	wallCast.scale.x = PlayerCollision.scale.x
	
	just_reset = true
	being_controlled = false
	just_started_control = false
	positioning_finished = false
	movement_overrider = null
	next_pos = Vector2(0,0)
	once_freed_angular_velocity = 0.0
	once_freed_linear_velocity = Vector2(0,0)
	controlled_ang_vel = 0.0
	controlled_lin_vel = Vector2(0,0)
	directPosControl = false

func _integrate_forces(state):
	if just_reset:
		state.set_transform(starting_transform)
		state.set_linear_velocity(Vector2())
		state.set_angular_velocity(0.0)
		just_reset = false
	
	if !being_controlled:
		state.set_linear_velocity(Vector2(current_direction.x * speed, linear_velocity.y))
	
	if just_started_control:
		just_started_control = false
		state.set_linear_velocity(Vector2())
		state.set_angular_velocity(0.0)
	if being_controlled:
		if !positioning_finished or directPosControl:
			var new_transform = state.get_transform()
			new_transform.origin = next_pos
			state.set_transform(new_transform)
			state.set_linear_velocity(Vector2())
			state.set_angular_velocity(0.0)
		else:
			state.set_linear_velocity(controlled_lin_vel + state.get_linear_velocity())
			state.set_angular_velocity(controlled_ang_vel + state.get_angular_velocity())
			clear_cont_vel()

func _physics_process(delta):
	if is_on_floor():
		rotate_player_on_slope(delta)
	else:
		rotate_player_on_arc(delta)
		
	if is_on_wall():
		current_direction = -current_direction
		AnimatedSprite.flip_h = !AnimatedSprite.flip_h
		PlayerCollision.scale.x *= -1
		wallCast.scale *= -1
		AnimatedSprite.offset.x += 8*PlayerCollision.scale.x
		#play the sound
		HitSounds.stream = load("res://Sounds/hitsomething.ogg")
		HitSounds.play()
	
func rotate_player_on_arc(delta):
	if being_controlled:
		# Calculate the angle between the player's current rotation and the target rotation (0 degrees).
		var target_angle = 0
		var current_angle = AnimatedSprite.rotation
		var angle_diff = target_angle - current_angle
		
		var rotation_speed = angle_diff * falling_rotation_speed
		
		# Rotate the player towards the target angle.
		AnimatedSprite.rotation += rotation_speed * delta
	elif !is_on_floor() and linear_velocity.x !=0:
		var arc_angle = atan2(linear_velocity.y, linear_velocity.x)  # Calculate the angle of the arc
		arc_angle += 0.0 if current_direction == Vector2.RIGHT else PI
		AnimatedSprite.rotation = lerp_angle(AnimatedSprite.rotation, arc_angle, falling_rotation_speed * delta)

func rotate_player_on_slope(delta):
	if is_on_floor() and linear_velocity.x != 0:
		floorCast.get_collision_normal()
		var slope_angle = Vector2.UP.angle_to(floorCast.get_collision_normal())
		AnimatedSprite.rotation += (slope_angle - AnimatedSprite.rotation) / time_to_rotate_slope * delta

func movement_overwritten(_movement_overrider):
	being_controlled = true
	just_started_control = true
	positioning_finished = false
	movement_overrider = _movement_overrider
	
func free_movement():
	being_controlled = false
	movement_overrider = null

func set_body_pos(pos):
	next_pos = pos

func positioningRideEnded(_directPosControl):
	positioning_finished = true
	directPosControl = _directPosControl

func set_freed_vel(ang_vel, lin_vel):
	once_freed_angular_velocity = ang_vel
	once_freed_linear_velocity = lin_vel

func add_to_freed_vel(ang_vel, lin_vel):
	once_freed_angular_velocity += ang_vel
	once_freed_linear_velocity += lin_vel

func clear_freed_velocity():
	once_freed_angular_velocity = 0.0
	once_freed_linear_velocity = Vector2()
	
func add_to_cont_vel(ang_vel, lin_vel):
	controlled_ang_vel = ang_vel
	controlled_lin_vel = lin_vel
	
func clear_cont_vel():
	controlled_ang_vel = 0.0
	controlled_lin_vel = Vector2()
	
func is_on_floor():
	return floorCollisions != 0

func is_on_wall():
	if wallCast.is_colliding():
		var wallNormal = wallCast.get_collision_normal()
		if(abs(rad_to_deg(atan2(wallNormal.x, wallNormal.y))) < 135):
			return true
	return false

func _on_floor_collision_area_body_entered(body):
	if(body == self):
		return
	floorCollisions += 1

func _on_floor_collision_area_body_exited(body):
	if(body == self):
		return
	floorCollisions -= 1
