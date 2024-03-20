extends RigidBody2D
class_name movingObject

@export var stickyMultiplier = 0.8
@export var magnetic: bool = false
@export var followPlayer: bool = true
@export var maxMagnetVelocity: float
@export var floorDetector: RayCast2D	
@export var sprite: Sprite2D
@export var SodaShield: AnimatedSprite2D
@export var collisionShape: CollisionShape2D
@export var soundPlayer: AudioStreamPlayer2D
@export var deathExplosion : Polygon2D

var levelPlayer : rigidPlayer

var just_destroyed = false
var destroyed = false
var starting_transform
var just_reset = true
var being_controlled = false
var just_started_control = false
var positioning_finished = false
var just_freed = false
var movement_overrider
var next_pos: Vector2
var once_freed_angular_velocity: float
var once_freed_linear_velocity: Vector2
var controlled_ang_vel: float = 0.0
var controlled_lin_vel: Vector2 = Vector2()
var directPosControl: bool = false
var last_vel_x : float = 0
var last_vel_y : float = 0
var inSoda : int = 0
var isShielded : bool = false
var magnetTriggers : Array[magnetTrigger]

func _ready():
	starting_transform = get_global_transform()
	reset()

func reset():
	just_reset = true
	being_controlled = false
	just_started_control = false
	positioning_finished = false
	just_freed = false
	movement_overrider = null
	next_pos = Vector2(0,0)
	once_freed_angular_velocity = 0.0
	once_freed_linear_velocity = Vector2(0,0)
	controlled_ang_vel = 0.0
	controlled_lin_vel = Vector2(0,0)
	directPosControl = false
	inSoda = 0
	isShielded = false
	SodaShield.visible = false
	
	just_destroyed = false
	destroyed = false
	sprite.show()
	deathExplosion.hide()
	collisionShape.set_deferred("disabled", false)

func destroy():
	if(isShielded):
		isShielded = false
		SodaShield.visible = false
		return
	just_destroyed = true
	destroyed = true
	sprite.hide()
	deathExplosion.show()
	deathExplosion.explode()
	collisionShape.set_deferred("disabled", true)
	#play sound
	#HitSounds.stream = load("res://Sounds/death.ogg")
	#HitSounds.play()
	#CrawlSounds.stop()

func GiveSodaShield():
	isShielded = true
	SodaShield.visible = true

func _physics_process(_delta):
	floorDetector.rotation = -rotation
	if followPlayer and levelPlayer != null:
		sprite.look_at(levelPlayer.global_position)

func _integrate_forces(state):
	#reset gravity scale
	gravity_scale = 1.0
	if inSoda < 0:
		inSoda = 0
	elif inSoda >= 1:
		gravity_scale = stickyMultiplier
	state.set_linear_velocity(state.linear_velocity * gravity_scale)
	state.set_angular_velocity(state.angular_velocity * gravity_scale)
	
	#magnetic field forces
	if magnetic:
		state.set_linear_velocity(calc_magnetic_forces(magnetTriggers) + state.get_linear_velocity())
	
	if just_destroyed:
		#state.set_linear_velocity(Vector2())
		state.set_angular_velocity(0.0)
		just_destroyed = false
	
	if just_reset:
		state.set_transform(starting_transform)
		state.set_linear_velocity(Vector2())
		state.set_angular_velocity(0.0)
		just_reset = false
	
	if just_started_control:
		just_started_control = false
		state.set_linear_velocity(Vector2())
		state.set_angular_velocity(0.0)
	if being_controlled or just_freed:
		if !positioning_finished or directPosControl:
			var new_transform = state.get_transform()
			new_transform.origin = next_pos
			state.set_transform(new_transform)
			state.set_linear_velocity(Vector2())
			state.set_angular_velocity(0.0)
		else:
			state.set_linear_velocity((controlled_lin_vel + state.get_linear_velocity()) * gravity_scale)
			state.set_angular_velocity((controlled_ang_vel + state.get_angular_velocity()) * gravity_scale)
			clear_cont_vel()
	if just_freed:
		just_freed = false
		state.set_linear_velocity(once_freed_linear_velocity * gravity_scale)
		state.set_angular_velocity(once_freed_angular_velocity * gravity_scale)
		#clear_freed_velocity()
	
	if (max(last_vel_x - linear_velocity.x, last_vel_y - linear_velocity.y) > 40):
		if (linear_velocity.y > -600):
			soundPlayer.volume_db = linear_to_db(max(last_vel_x - linear_velocity.x, last_vel_y - linear_velocity.y)/100)
			soundPlayer.play()
		last_vel_x = linear_velocity.x
		last_vel_y = linear_velocity.y
	if (!being_controlled):
		last_vel_x = linear_velocity.x
		last_vel_y = linear_velocity.y

func calc_magnetic_forces(magnets:Array[magnetTrigger]):
	var magnetic_linear_velocity = Vector2()
	for magnet in magnets:
		var direction = magnet.location - global_position
		direction = direction.normalized()
		
		var distance = global_position.distance_to(magnet.location)
		
		#Change this section to change how fast the force shrinks over distance
		#Real life is distance^2, which just feels terrible
		var force = magnet.strength / sqrt(distance)
		force = clamp(force, -maxMagnetVelocity, maxMagnetVelocity)
		
		magnetic_linear_velocity += direction * force
	return magnetic_linear_velocity

func movement_overwritten(_movement_overrider):
	being_controlled = true
	just_started_control = true
	positioning_finished = false
	movement_overrider = _movement_overrider
	
func free_movement():
	being_controlled = false
	movement_overrider = null
	just_freed = true

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
	if (linear_velocity.y >= 0):
		return floorDetector.is_colliding()
	return false

func setPlayer(_player : rigidPlayer):
	levelPlayer = _player
