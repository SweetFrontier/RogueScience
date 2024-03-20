extends baseTrigger

class_name magnetTrigger

@export var strengthAmplitude: float
@export var startingPolarity: MagnetState
@export var magnetSprite: AnimatedSprite2D
@export var magneticSourcePoint: Marker2D

var currState: MagnetState
var lastPolarityState: MagnetState
var strength: float
var location: Vector2

enum MagnetState
{
	PULLING,
	NEUTRAL,
	PUSHING
}

var stateToAnimString = {
	MagnetState.PULLING: "pulling",
	MagnetState.NEUTRAL: "neutral",
	MagnetState.PUSHING: "pushing"
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
			lastPolarityState = MagnetState.PULLING
			currState = MagnetState.NEUTRAL
			strength = -strengthAmplitude
		MagnetState.PUSHING:
			lastPolarityState = MagnetState.PUSHING
			currState = MagnetState.NEUTRAL
			strength = strengthAmplitude
		MagnetState.NEUTRAL:
			currState = MagnetState.PULLING if lastPolarityState == MagnetState.PUSHING else MagnetState.PUSHING
	magnetSprite.animation = stateToAnimString[currState]
	magnetSprite.frame = 0

func reset():
	super.reset()
	magnetSprite.animation = "inactive"
	magnetSprite.frame = 0
	currState = startingPolarity
	lastPolarityState = MagnetState.PULLING if startingPolarity == MagnetState.PULLING else MagnetState.PUSHING
	strength = 0

func _process(_delta):
	pass
