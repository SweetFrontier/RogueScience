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
@export var fallingThreshold : int = 160

@export var deathExplosion : Polygon2D
@export var deathBounceRequirement : int = 5; # number of frames in a row must turn before explode
@export var won_level : bool = false

signal player_death_signal

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
var setBodyPos: bool = false
var last_y_velocity : float = 0 #last_y_velocity for how loud to play the hit sound
var deathCounter = 0
var dead : bool = false
var animBackwards = false

func _ready():
	last_y_velocity = 0
	dead = false
	starting_transform = get_global_transform()
	reset()

func reset():
	AnimatedSprite.animation = "crawl"
	AnimatedSprite.show()
	current_direction = starting_direction
	AnimatedSprite.rotation = 0.0
	if current_direction == Vector2.RIGHT:
		AnimatedSprite.flip_h = false
		PlayerCollision.scale.x = abs(PlayerCollision.scale.x)
		AnimatedSprite.offset.x = 4
		#start facing right, wallcast can collide with left side of blocks
		wallCast.set_collision_mask_value(3, false) # 3 is oneWayBlockRHS
		wallCast.set_collision_mask_value(4, true) # 4 is oneWayBlockLHS
	if current_direction == Vector2.LEFT:
		AnimatedSprite.flip_h = true
		PlayerCollision.scale.x = -1 * abs(PlayerCollision.scale.x)
		AnimatedSprite.offset.x = -4
		#start facing left, wallcast can collide with right side of blocks
		wallCast.set_collision_mask_value(3, true) # 3 is oneWayBlockRHS
		wallCast.set_collision_mask_value(4, false) # 4 is oneWayBlockLHS
	wallCast.scale.x = PlayerCollision.scale.x
	CrawlSounds.play()
	
	just_reset = true
	dead = false
	set_process(PROCESS_MODE_INHERIT)
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
	last_y_velocity = 0

func _integrate_forces(state):
	if just_reset:
		#debug line, force to show again because of a glitch
		AnimatedSprite.show()
		state.set_transform(starting_transform)
		state.set_linear_velocity(Vector2())
		state.set_angular_velocity(0.0)
		just_reset = false
	
	if !being_controlled && !dead:
		state.set_linear_velocity(Vector2(current_direction.x * speed, state.get_linear_velocity().y))
	
	if just_started_control:
		just_started_control = false
		state.set_linear_velocity(Vector2())
		state.set_angular_velocity(0.0)
	if being_controlled or setBodyPos:
		if !positioning_finished or directPosControl or setBodyPos:
			var new_transform = state.get_transform()
			new_transform.origin = next_pos
			state.set_transform(new_transform)
			state.set_linear_velocity(Vector2())
			state.set_angular_velocity(0.0)
			if setBodyPos:
				setBodyPos = false
		else:
			state.set_linear_velocity(controlled_lin_vel + state.get_linear_velocity())
			state.set_angular_velocity(controlled_ang_vel + state.get_angular_velocity())
			clear_cont_vel()

func _physics_process(delta):
	if !dead:
		if is_on_floor():
			rotate_player_on_slope(delta)
			if !won_level:
				#if on ground then play crawling sound again
				if (!CrawlSounds.playing && is_on_floor() && !being_controlled):
					CrawlSounds.play()
				#check if crashing, and if so, play sound
				if (last_y_velocity > 40):
					# play the louder one if fall from high up
					if (last_y_velocity > 600):
						HitSounds.stream = load("res://Sounds/hitgroundfromhigh.ogg")
					else:
						HitSounds.stream = load("res://Sounds/hitsomething.ogg")
					last_y_velocity = 0
					HitSounds.play()
		else:
			rotate_player_on_arc(delta)
			if (linear_velocity.y > fallingThreshold):
				CrawlSounds.stop()
				last_y_velocity = linear_velocity.y
	
		if being_controlled:
			CrawlSounds.stop()
			return
		
		if is_on_wall() and !won_level:
			deathCounter += 1
			current_direction = -current_direction
			AnimatedSprite.flip_h = !AnimatedSprite.flip_h
			PlayerCollision.scale.x *= -1
			wallCast.scale *= -1
			AnimatedSprite.offset.x += 8*PlayerCollision.scale.x
			#play the sound
			HitSounds.stream = load("res://Sounds/hitsomething.ogg")
			HitSounds.play()
			#set wallcast to current direction
			if (current_direction.x < 0):
				#facing left, wallcast can collide with right side of blocks
				wallCast.set_collision_mask_value(3, true) # 3 is oneWayBlockRHS
				wallCast.set_collision_mask_value(4, false) # 4 is oneWayBlockLHS
			else:
				#facing right, wallcast can collide with left side of blocks
				wallCast.set_collision_mask_value(3, false) # 3 is oneWayBlockRHS
				wallCast.set_collision_mask_value(4, true) # 4 is oneWayBlockLHS
			
			if (deathCounter >= deathBounceRequirement):
				killFella()
				#make dead
		else:
			deathCounter = 0
	
	#set current L/R collision mask
	if (linear_velocity.x > 0):
		# if moving right, collide with only left walls
		set_collision_mask_value(3, false) # 3 is oneWayBlockRHS
		set_collision_mask_value(4, true) # 4 is oneWayBlockLHS
	else:
		# if moving left, collide with only right walls
		set_collision_mask_value(3, true) # 3 is oneWayBlockRHS
		set_collision_mask_value(4, false) # 4 is oneWayBlockLHS
	#set oneWay collision mask
	if (linear_velocity.y > -fallingThreshold):
		set_collision_mask_value(2, true) # 2 is vertical oneWayBlock
	else:
		set_collision_mask_value(2, false) # 2 is vertical oneWayBlock

func killFella():
	deathCounter = 0
	dead = true
	AnimatedSprite.hide()
	deathExplosion.show()
	deathExplosion.explode()
	set_process(PROCESS_MODE_DISABLED)
	#play sound
	HitSounds.stream = load("res://Sounds/death.ogg")
	HitSounds.play()
	CrawlSounds.stop()
	emit_signal("player_death_signal")

func rotate_player_on_arc(delta):
	if being_controlled and not positioning_finished:
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
	AnimatedSprite.play("walkedIntoTrigger")
	animBackwards = false
	movement_overrider = _movement_overrider
	
func free_movement():
	AnimatedSprite.play_backwards("walkedIntoTrigger")
	animBackwards = true
	being_controlled = false
	movement_overrider = null

func player_anim_finished():
	if AnimatedSprite.animation == "walkedIntoTrigger" and !being_controlled:
		AnimatedSprite.play("crawl")
		animBackwards = false
	elif being_controlled:
		if !positioning_finished:
			AnimatedSprite.play("chillinInTrigger")
			animBackwards = false
		elif linear_velocity.y < 0:
			if (AnimatedSprite.animation == "changingVerticalDirection" and animBackwards == true) or AnimatedSprite.animation == "rising" or AnimatedSprite.animation == "walkedIntoTrigger":
				AnimatedSprite.play("rising")
				animBackwards = false
			else:
				AnimatedSprite.play_backwards("changingVerticalDirection")
				animBackwards = true
		elif  linear_velocity.y > 0:
			if (AnimatedSprite.animation == "changingVerticalDirection" and animBackwards == false) or AnimatedSprite.animation == "falling" or AnimatedSprite.animation == "walkedIntoTrigger":
				AnimatedSprite.play("falling")
				animBackwards = false
			else:
				AnimatedSprite.play("changingVerticalDirection")
				animBackwards = false

func set_body_pos(pos):
	next_pos = pos
	setBodyPos = true

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

func won_level_silence():
	won_level = true
	CrawlSounds.stop()
