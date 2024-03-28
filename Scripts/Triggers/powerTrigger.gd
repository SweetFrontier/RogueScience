extends baseTrigger

class_name powerTrigger

@export var powerSourceSprite: AnimatedSprite2D
@export var exportConduits: Array[Node2D]

var currState : PowerState = PowerState.OFF

enum PowerState
{
	ON,
	OFF
}

var stateToAnimString = {
	PowerState.ON: "on",
	PowerState.OFF: "off"
}

# Called when the node enters the scene tree for the first time.
func _ready():
	TriggerKeySprite.rotation_degrees = -rotation_degrees
	currState = PowerState.OFF
	reset()

func _input(event):
	# Check if the associated button is pressed and the trigger is active.
	if event is InputEventKey and event.keycode == button and event.pressed and event.echo == false:
		react()  # Call the react method when the button is pressed.

func react():
	activated = true
	if (currState == PowerState.OFF):
		currState = PowerState.ON
		powerSourceSprite.animation = stateToAnimString[currState]
		powerSourceSprite.frame = 0
		releasePower()

func reset():
	super.reset()
	currState = PowerState.OFF
	powerSourceSprite.animation = stateToAnimString[currState]
	powerSourceSprite.frame = 0
	if startActivated:
		react()

func releasePower():
	for exportConduit in exportConduits:
		if exportConduit is wire or exportConduit is electrode:
			exportConduit.power(self)
	currState = PowerState.OFF
	powerSourceSprite.animation = stateToAnimString[currState]

func onAdjacentConduitFound(_area_rid, area, _area_shape_index, _local_shape_index):
	var areaParent = area.get_parent()
	if areaParent is wire or (areaParent is electrode and area.name != "ArcDetection") or areaParent is powerTrigger:
		exportConduits.append(areaParent)
