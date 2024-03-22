extends baseTrigger

class_name magnetTrigger

@export var strengthAmplitude: float
@export var startingPolarity: MagnetState
@export var magnetSprite: AnimatedSprite2D
@export var magneticSourcePoint: Marker2D

var currState: MagnetState
var strength: float
var location: Vector2

enum MagnetState
{
	PULLING,
	NEUTRALPUSH,
	PUSHING,
	NEUTRALPULL
}

var stateToAnimString = {
	MagnetState.PULLING: "pulling",
	MagnetState.NEUTRALPUSH: "neutralPush",
	MagnetState.PUSHING: "pushing",
	MagnetState.NEUTRALPULL: "neutralPull"
}

# Called when the node enters the scene tree for the first time.
func _ready():
	TriggerKeySprite.rotation_degrees = -rotation_degrees
	currState = startingPolarity
	location = magneticSourcePoint.global_position
	reset()

func _input(event):
	# Check if the associated button is pressed and the trigger is active.
	if event is InputEventKey and event.keycode == button and event.pressed and event.echo == false:
		react()  # Call the react method when the button is pressed.

func react():
	activated = true
	match currState:
		MagnetState.PULLING:
			currState = MagnetState.NEUTRALPUSH
			strength = 0
		MagnetState.NEUTRALPUSH:
			currState = MagnetState.PUSHING
			strength = strengthAmplitude
		MagnetState.PUSHING:
			currState = MagnetState.NEUTRALPULL
			strength = 0
		MagnetState.NEUTRALPULL:
			currState = MagnetState.PULLING
			strength = -strengthAmplitude
	magnetSprite.animation = stateToAnimString[currState]
	magnetSprite.frame = 0

func reset():
	super.reset()
	magnetSprite.animation = "inactive"
	magnetSprite.frame = 0
	currState = startingPolarity
	strength = 0
	if startActivated:
		react()
