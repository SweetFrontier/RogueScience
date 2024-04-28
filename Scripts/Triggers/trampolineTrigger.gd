extends baseTrigger
class_name trampolineTrigger

# Exported variable for controlling the jump force.
@export var jump_force: float = 500.0
@export var area2D: Area2D
@export var BlockSprite: AnimatedSprite2D
@export var MoveToPosition: Node2D
@export var Sound: AudioStreamPlayer2D
@export var instantSetup: bool = false

var rider_freeable = false

func _ready():
	super._ready()
	area2D.body_entered.connect(_on_body_entered)
	area2D.body_exited.connect(_on_body_exited)
	TriggerKeySprite.rotation_degrees = -rotation_degrees
	reset()

func react():
	super.react()
	if !activated:
		area2D.monitoring = true
		activated = true
		BlockSprite.animation = "activated"
		BlockSprite.frame = 0

func reset():
	super.reset()
	area2D.monitoring = false
	BlockSprite.animation = "deactivated"
	if startActivated:
		react()
		if show_button:
			button_fade_timer = 0
			TriggerKeySprite.modulate.a = 0

func _physics_process(delta):
	super._physics_process(delta)
	if !occupied:
		return
	if ridingBody is rigidPlayer:
		ridingBody.rotate_player_on_arc(delta)
	if !riderInPosition:
		#if ridingBody is rigidPlayer:
		#	ridingBody.rotate_player_on_arc(delta)
		moveRiderToStarting(delta)
	else:
		if ridingBody.is_on_floor() and rider_freeable:
			free_movement()

func _on_body_entered(body):
	if !body is movingObject and !body is rigidPlayer:
		return
	if body == ridingBody:
		override_movement(body)
		body.set_body_pos(global_position)
		riderReady()
		rider_freeable = false
	elif activated and !occupied and body != self:
		override_movement(body)
		if abs(body.global_position.x-global_position.x) <= 5 or instantSetup:
			body.set_body_pos(global_position)
			riderReady()
		else:
			setupMoveToStart()
			#if body is movingObject:
				#body.set_freed_vel(body.angular_velocity, body.linear_velocity)
		rider_freeable = false

func _on_body_exited(body):
	if occupied and body == ridingBody:
		BlockSprite.frame = 0
		rider_freeable = true
	
func setupMoveToStart():
	super.setupMoveToStart()
	#endRiderPos = position + MoveToPosition.global_position
	endRiderPos = MoveToPosition.global_position
	BlockSprite.frame = 1

func riderReady():
	super.riderReady()
	Sound.play()
	if ridingBody is movingObject or ridingBody is rigidPlayer:
		ridingBody.positioningRideEnded(false)
		ridingBody.add_to_cont_vel(0.0, Vector2(0, -jump_force).rotated(deg_to_rad(rotation_degrees)))
		if ridingBody is rigidPlayer and rotation_degrees*ridingBody.current_direction.x < 0:
			ridingBody.current_direction = -ridingBody.current_direction
			ridingBody.AnimatedSprite.flip_h = !ridingBody.AnimatedSprite.flip_h
			ridingBody.PlayerCollision.scale.x *= -1
			ridingBody.wallCast.scale *= -1
			ridingBody.AnimatedSprite.offset.x += 8*ridingBody.PlayerCollision.scale.x
	else:
		ridingBody.velocity = Vector2(0, -jump_force)
	rider_freeable = false
