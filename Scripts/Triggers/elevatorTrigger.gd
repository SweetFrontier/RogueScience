extends baseTrigger
class_name elevatorTrigger

# Exported variable for controlling the suction force.
@export var time_to_change_stops: float = 1
@export var ElevatorShaft: AnimatedSprite2D
@export var ElevatorBox: AnimatedSprite2D
@export var ElevatorArea: Area2D
@export var stoppingPoints: Array[AnimatedSprite2D]
@export var ActivateSound: AudioStreamPlayer2D
@export var BuzzSound: AudioStreamPlayer2D
@export var startingStop: int = 0
@export var startingMovingUp: bool = true

var elevatingBeginPos: Vector2
var elevatingEndPos: Vector2
var elevatingProgress: float
var moving_up = true
var moving_elevator = false
var reached_stop = false
var curr_stop = 0

func _ready():
	super._ready()
	ElevatorArea.body_entered.connect(_on_body_entered)
	ElevatorArea.body_exited.connect(_on_body_exited)
	reset()

func react():
	super.react()
	if !activated:
		activated = true
		for child in $ElevatorStops.get_children():
			child.play("activated")
		ElevatorShaft.play("activated")
		ElevatorBox.play("activated")
		BuzzSound.play()
		ActivateSound.play()

func reset():
	super.reset()
	elevatingBeginPos = Vector2(0,0)
	elevatingEndPos = Vector2(0,0)
	elevatingProgress = 0.0
	moving_up = startingMovingUp
	moving_elevator = false
	reached_stop = false
	curr_stop = startingStop
	ElevatorBox.global_position = stoppingPoints[curr_stop].global_position
	#make sure everything is deactivated
	for child in $ElevatorStops.get_children():
		child.animation = "deactivated"
	ElevatorShaft.animation = "deactivated"
	ElevatorBox.animation = "deactivated"
	BuzzSound.stop()
	if startActivated:
		react()
		button_fade_timer = 0
		TriggerKeySprite.modulate.a = 0

func _physics_process(delta):
	super._physics_process(delta)
	if !occupied or reached_stop:
		return
	if !riderInPosition:
		if ridingBody is Player:
			ridingBody.rotate_player_on_arc(delta)
		moveRiderToStarting(delta)
	if moving_elevator:
		moveElevator(delta)

func _on_body_entered(body):
	if !body is Player and !body is movingObject and !body is rigidPlayer:
		return
	if activated and body != self and !occupied and body != ridingBody:
		override_movement(body)
		setupMoveToStart()
		if body is movingObject:
			body.set_freed_vel(body.angular_velocity, body.linear_velocity)

func _on_body_exited(body):
	# Check if the exited body was inside the elevator.
	if activated and occupied and body == ridingBody and !moving_elevator:
		occupied = false
		ridingBody = null

func setupMoveToStart():
	super.setupMoveToStart()
	endRiderPos = ElevatorBox.global_position
	reached_stop = false

func riderReady():
	super.riderReady()
	setupElevatorStarting()
	if ridingBody is movingObject or ridingBody is rigidPlayer:
		ridingBody.positioningRideEnded(true)

func setupElevatorStarting():
	elevatingProgress = 0.0
	elevatingBeginPos = stoppingPoints[curr_stop].global_position
	if curr_stop == 0:
		moving_up = true
	elif curr_stop == stoppingPoints.size()-1:
		moving_up = false
	
	if moving_up:
		elevatingEndPos = stoppingPoints[curr_stop+1].global_position
		curr_stop += 1
	else:
		elevatingEndPos = stoppingPoints[curr_stop-1].global_position
		curr_stop -= 1
	moving_elevator = true

func moveElevator(delta):
	elevatingProgress += delta
	ElevatorBox.global_position = (elevatingEndPos - elevatingBeginPos) * (elevatingProgress/time_to_change_stops)  + elevatingBeginPos
	ridingBody.set_body_pos(ElevatorBox.global_position)
	# Check if the interpolation is complete.
	if elevatingProgress >= time_to_change_stops:
		ElevatorBox.global_position = elevatingEndPos
		ridingBody.set_body_pos(ElevatorBox.global_position)
		moving_elevator = false
		reached_stop = true
		free_movement()
