extends baseTrigger
class_name elevatorTrigger

# Exported variable for controlling the suction force.
@export var time_to_change_stops: float = 1
@export var ElevatorShaft: AnimatedSprite2D
@export var ElevatorBox: AnimatedSprite2D
@export var ElevatorArea: Area2D
@export var stoppingPoints: Array[AnimatedSprite2D]

var elevatingBeginPos: Vector2
var elevatingEndPos: Vector2
var elevatingProgress: float
var moving_up = true
var moving_elevator = false
var curr_stop = 0
var reached_stop = false

func _ready():
	super._ready()
	if activated:
		activated = false
		react()
	else:
		reset()
	ElevatorArea.body_entered.connect(_on_body_entered)
	ElevatorArea.body_exited.connect(_on_body_exited)

func react():
	super.react()
	if !activated:
		activated = true

func reset():
	super.reset()

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
	if activated and body != self and !occupied and body != ridingBody:
		override_movement(body)
		setupMoveToStart()

func _on_body_exited(body):
	# Check if the exited body was inside the elevator.
	if occupied and body == ridingBody:
		occupied = false
		ridingBody = null

func setupMoveToStart():
	super.setupMoveToStart()
	endRiderPos = position + ElevatorBox.position
	reached_stop = false

func riderReady():
	super.riderReady()
	setupElevatorStarting()

func setupElevatorStarting():
	elevatingProgress = 0.0
	elevatingBeginPos = stoppingPoints[curr_stop].position
	if curr_stop == 0:
		moving_up = true
	elif curr_stop == stoppingPoints.size()-1:
		moving_up = false
	
	if moving_up:
		elevatingEndPos = stoppingPoints[curr_stop+1].position
		curr_stop += 1
	else:
		elevatingEndPos = stoppingPoints[curr_stop-1].position
		curr_stop -= 1
	moving_elevator = true

func moveElevator(delta):
	elevatingProgress += delta
	ElevatorBox.position = (elevatingEndPos - elevatingBeginPos) * (elevatingProgress/time_to_change_stops) + elevatingBeginPos
	ridingBody.position = ElevatorBox.position + position
	# Check if the interpolation is complete.
	if elevatingProgress >= time_to_change_stops:
		ElevatorBox.position = elevatingEndPos
		ridingBody.position = ElevatorBox.position + position
		moving_elevator = false
		reached_stop = true
		free_movement()
