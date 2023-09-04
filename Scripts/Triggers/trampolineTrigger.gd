extends baseTrigger
class_name trampolineTrigger

# Exported variable for controlling the jump force.
@export var jump_force: float = 500.0
@export var area2D: Area2D
@export var BlockSprite: AnimatedSprite2D
@export var MoveToPosition: Node2D

var player_freeable = false

func _ready():
	super._ready()
	if activated:
		activated = false
		react()
	else:
		reset()
	area2D.body_entered.connect(_on_body_entered)
	area2D.body_exited.connect(_on_body_exited)

func react():
	super.react()
	if(!activated):
		activated = true
	BlockSprite.animation = "activated"
	BlockSprite.frame = 0

func reset():
	super.reset()
	BlockSprite.animation = "deactivated"

func _physics_process(delta):
	super._physics_process(delta)
	if !occupied:
		return
	if !riderInPosition:
		if ridingBody is Player:
			ridingBody.rotate_player_on_arc(delta)
		moveRiderToStarting(delta)
	else:
		if ridingBody.is_on_floor() and player_freeable:
			free_movement()
			ridingBody = null
			occupied = false
		else:
			ridingBody.velocity.y += gravity * delta
			ridingBody.move_and_slide()

func _on_body_entered(body):
	if activated and body != self and !occupied and body != ridingBody:
		override_movement(body)
		setupMoveToStart()
		player_freeable = false
	elif body == ridingBody:
		riderReady()
		player_freeable = false

func _on_body_exited(body):
	if occupied and body == ridingBody:
		BlockSprite.frame = 0
		player_freeable = true
	
func setupMoveToStart():
	super.setupMoveToStart()
	endRiderPos = position + MoveToPosition.position
	BlockSprite.frame = 1

func riderReady():
	super.riderReady()
	if ridingBody is RigidBody2D:
		ridingBody.apply_impulse(Vector2(0, -jump_force*3))
	elif ridingBody is Player:
		ridingBody.velocity = Vector2(0, -jump_force)
		player_freeable = false
