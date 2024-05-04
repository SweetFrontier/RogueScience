extends baseTrigger

class_name magnetTrigger

@export var strengthAmplitude: float
@export var startingPolarity: MagnetState
@export var startLocked: bool = false
@export var magnetSprite: AnimatedSprite2D
@export var magneticSourcePoint: Marker2D
@export var sounds: AudioStreamPlayer2D

var currState: MagnetState
var strength: float
var location: Vector2
var locked = false

var magtivationSound = preload("res://Sounds/magtivation.ogg")
var demagtivationSound = preload("res://Sounds/demagtivation.ogg")

enum MagnetState
{
	PULLING,
	NEUTRALPUSH,
	PUSHING,
	NEUTRALPULL,
	LOCKED
}

var stateToAnimString = {
	MagnetState.PULLING: "pulling",
	MagnetState.NEUTRALPUSH: "neutralPush",
	MagnetState.PUSHING: "pushing",
	MagnetState.NEUTRALPULL: "neutralPull",
	MagnetState.LOCKED: "locked"
}

# Called when the node enters the scene tree for the first time.
func _ready():
	TriggerKeySprite.rotation_degrees = -rotation_degrees
	currState = startingPolarity
	location = magneticSourcePoint.global_position
	reset()

func reset():
	super.reset()
	locked = false
	if !show_button:
		TriggerKeySprite.modulate.a = 0
	setState(startingPolarity)
	if startActivated:
		react()
	if startLocked:
		lock()

func react():
	if (activated and one_shot) or locked:
		return
	activated = true
	match currState:
		MagnetState.PULLING:
			currState = MagnetState.NEUTRALPUSH
			strength = 0
			sounds.stream = demagtivationSound
		MagnetState.NEUTRALPUSH:
			currState = MagnetState.PUSHING
			strength = strengthAmplitude
			sounds.stream = magtivationSound
		MagnetState.PUSHING:
			currState = MagnetState.NEUTRALPULL
			strength = 0
			sounds.stream = demagtivationSound
		MagnetState.NEUTRALPULL:
			currState = MagnetState.PULLING
			strength = -strengthAmplitude
			sounds.stream = magtivationSound
	sounds.play()
	magnetSprite.animation = stateToAnimString[currState]
	magnetSprite.frame = 0

func setState(newState : MagnetState):
	currState = newState
	magnetSprite.animation = stateToAnimString[currState]
	magnetSprite.frame = 0
	match currState:
		MagnetState.NEUTRALPUSH, MagnetState.NEUTRALPULL, MagnetState.LOCKED:
			strength = 0
		MagnetState.PULLING:
			strength = -strengthAmplitude
		MagnetState.PUSHING:
			strength = strengthAmplitude

func lock():
	locked = true
	setState(MagnetState.LOCKED)
	TriggerKeySprite.modulate.a = 0

func unlock():
	locked = false
	setState(startingPolarity)
	if show_button:
		TriggerKeySprite.modulate.a = 1
