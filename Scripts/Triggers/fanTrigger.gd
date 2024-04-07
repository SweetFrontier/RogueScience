extends baseTrigger

class_name fanTrigger

@export var strengthAmplitude: float
@export var fanSprite: AnimatedSprite2D
@export var pushArea: Area2D

var currState: FanState
var strength: float

enum FanState
{
	ON,
	OFF
}

var stateToAnimString = {
	FanState.ON: "on",
	FanState.OFF: "off"
}

# Called when the node enters the scene tree for the first time.
func _ready():
	TriggerKeySprite.rotation_degrees = -rotation_degrees
	if !show_button:
		TriggerKeySprite.modulate.a = 0
	currState = FanState.OFF
	reset()

func react():
	activated = true
	if currState == FanState.OFF:
		currState = FanState.ON
		strength = strengthAmplitude
		pushArea.monitoring = true
		#$PushArea/CollisionShape2D.shape.size.y = 96
	else:
		currState = FanState.OFF
		strength = 0
		pushArea.monitoring = false
		#$PushArea/CollisionShape2D.shape.size.y = 0
	fanSprite.animation = stateToAnimString[currState]
	fanSprite.frame = 0
	fanSprite.play()

func reset():
	super.reset()
	currState = FanState.OFF
	fanSprite.animation = stateToAnimString[currState]
	fanSprite.frame = 0
	fanSprite.play()
	strength = 0
	if startActivated:
		react()

func onPushBodyEntered(body):
	print(body, " entered")

func onPushBodyExited(body):
	print(body, " exited")
