extends baseTrigger

class_name fanTrigger

@export var strengthAmplitude: float
@export var fanSprite: AnimatedSprite2D
@export var pushArea: Area2D
@export var audio: AudioStreamPlayer2D
@export var fanimator: AnimationPlayer
@export var windSprites: Array[AnimatedSprite2D]

var currState: FanState
var strength: float
var direction: Vector2

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
	#calculate Vector2 direction premptively
	direction = Vector2(cos(global_rotation), sin(global_rotation)).normalized()
	
	TriggerKeySprite.rotation_degrees = -rotation_degrees
	if !show_button:
		TriggerKeySprite.modulate.a = 0
	currState = FanState.OFF
	audio.pitch_scale = randf_range(0.75, 1.25)
	reset()

func react():
	activated = true
	if currState == FanState.OFF:
		currState = FanState.ON
		strength = strengthAmplitude
		pushArea.monitoring = true
		for wind in windSprites:
			wind.show()
		fanimator.play("on")
	else:
		currState = FanState.OFF
		strength = 0
		pushArea.monitoring = false
		#for wind in windSprites:
		#	wind.hide()
		fanimator.play("off")
	fanSprite.animation = stateToAnimString[currState]
	fanSprite.frame = 0
	fanSprite.play()

func reset():
	super.reset()
	currState = FanState.OFF
	fanSprite.animation = stateToAnimString[currState]
	fanSprite.frame = 0
	pushArea.monitoring = false
	fanSprite.play()
	fanimator.stop()
	audio.stop()
	for wind in windSprites:
			wind.hide()
	strength = 0
	if startActivated:
		react()

func onPushBodyEntered(body):
	if body is rigidPlayer or body is movingObject or body is boss:
		var bodyFans = body.fansInRange
		if not self in bodyFans:
			bodyFans.append(self)

func onPushBodyExited(body):
	if body is rigidPlayer or body is movingObject or body is boss:
		var bodyFans = body.fansInRange
		var index = bodyFans.find(self)
		if index != -1:
			bodyFans.remove_at(index)
