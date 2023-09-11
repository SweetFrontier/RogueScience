extends RigidBody2D
class_name movingObject

@export var floorDetector: RayCast2D
@export var sprite: Sprite2D

var levelPlayer : Player

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

func _ready():
	starting_transform = get_transform()
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

func _physics_process(_delta):
	floorDetector.rotation = -rotation
	if levelPlayer != null:
		
		sprite.look_at(levelPlayer.position)

func _integrate_forces(state):
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
			state.set_linear_velocity(controlled_lin_vel + state.get_linear_velocity())
			state.set_angular_velocity(controlled_ang_vel + state.get_angular_velocity())
			clear_cont_vel()
	if just_freed:
		just_freed = false
		state.set_linear_velocity(once_freed_linear_velocity)
		state.set_angular_velocity(once_freed_angular_velocity)

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
	return floorDetector.is_colliding()
	
func setPlayer(_player : Player):
	levelPlayer = _player
