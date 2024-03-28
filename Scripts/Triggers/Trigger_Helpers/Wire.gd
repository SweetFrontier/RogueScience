extends Node2D

class_name wire

@export var wireSprite: AnimatedSprite2D

@export var overrideUL : Node2D
@export var overrideU : Node2D
@export var overrideUR : Node2D
@export var overrideL : Node2D
@export var overrideR : Node2D
@export var overrideDL : Node2D
@export var overrideD : Node2D
@export var overrideDR : Node2D

var currState : PowerState = PowerState.OFF
var connections : Array[Node2D]
var poweringConnection : Node2D
var outputConnections: Array[Node2D]

enum PowerState
{
	ON,
	OFF
}

var stateToAnimString = {
	PowerState.ON: "on",
	PowerState.OFF: "off"
}

func _ready():
	connections = [overrideUL, overrideU, overrideUR, overrideL, overrideR, overrideDL, overrideD, overrideDR]
	reset()

func reset():
	currState = PowerState.OFF
	wireSprite.animation = stateToAnimString[currState]
	wireSprite.frame = 0
	poweringConnection = null
	outputConnections.clear()
	
func power(inputConn):
	if not inputConn in connections:
		print_debug("inputConn not in connections")
		return
	if currState == PowerState.OFF:
		poweringConnection = inputConn
		for connection in connections:
			if !connection:
				continue
			if connection != poweringConnection:
				outputConnections.append(connection)
		currState = PowerState.ON
		wireSprite.animation = stateToAnimString[currState]
		wireSprite.play()

func onWireSpriteFrameChanged():
	if wireSprite.frame == 3 and wireSprite.animation == stateToAnimString[PowerState.ON]:
		for output in outputConnections:
			if output is wire or output is electrode:
				output.power(self)

func onWireSpriteAnimationFinished():
	if wireSprite.animation == stateToAnimString[PowerState.ON]:
		reset()

func onAdjacentConduitFound(_area_rid, area, _area_shape_index, _local_shape_index, areaDirection):
	var areaParent = area.get_parent()
	if areaParent is wire or (areaParent is electrode and area.name != "ArcDetection") or areaParent is powerTrigger:
		if !connections[areaDirection]:
			connections[areaDirection] = areaParent
