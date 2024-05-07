extends baseTrigger

class_name powerTrigger

@export var powerSourceSprite: AnimatedSprite2D
@export var exportConduits: Array[Node2D]
@export var startLocked: bool = false

var currState : PowerState = PowerState.OFF
var locked : bool = false

enum PowerState
{
	ON,
	OFF,
	LOCKED
}

var stateToAnimString = {
	PowerState.ON: "on",
	PowerState.OFF: "off",
	PowerState.LOCKED: "locked"
}

# Called when the node enters the scene tree for the first time.
func _ready():
	TriggerKeySprite.rotation_degrees = -rotation_degrees
	if !show_button:
		TriggerKeySprite.modulate.a = 0
	currState = PowerState.OFF
	$WireDetection.monitoring = false
	$WireDetection.monitorable = false

func _input(event):
	# Check if the associated button is pressed and the trigger is active.
	if event is InputEventKey and event.keycode == button and event.pressed and event.echo == false:
		react()  # Call the react method when the button is pressed.

func react():
	if (activated and one_shot) or locked:
		return
	activated = true
	if (currState == PowerState.OFF):
		setState(PowerState.ON)
		#releasePower()

func reset():
	super.reset()
	$WireDetection.monitoring = true
	$WireDetection.monitorable = true
	
	locked = false
	
	setState(PowerState.OFF)
	if startLocked:
		locked = true
	if startActivated:
		react()

func releasePower():
	for exportConduit in exportConduits:
		if exportConduit is wire or exportConduit is electrode:
			exportConduit.power(self)
		elif exportConduit is baseTrigger:
			exportConduit.react()
	setState(PowerState.OFF)

func onAdjacentConduitFound(_area_rid, area, _area_shape_index, _local_shape_index):
	var areaParent = area.get_parent()
	if areaParent is wire or (areaParent is electrode and area.name != "ArcDetection") or areaParent is powerTrigger or areaParent is baseTrigger:
		#powerTrigger will only be able to detect other powerTriggers or baseTriggers, as it has its collision turned on first
		if areaParent is powerTrigger and not self in areaParent.exportConduits:
			areaParent.exportConduits.append(self)
		elif areaParent is baseTrigger:
			areaParent.show_button = false
			areaParent.TriggerKeySprite.modulate.a = 0
		exportConduits.append(areaParent)

func setState(newState : PowerState):
	currState = newState
	powerSourceSprite.animation = stateToAnimString[currState]
	powerSourceSprite.frame = 0
	powerSourceSprite.play()

func lock():
	locked = true
	setState(PowerState.LOCKED)

func unlock():
	locked = false
	setState(PowerState.OFF)

func onPowerSourceSpriteFrameChanged():
	if powerSourceSprite.animation == stateToAnimString[PowerState.ON]:
		if powerSourceSprite.frame == 3:
			releasePower()
