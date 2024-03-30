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

var wireDetectors : Array[Area2D]
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
	wireDetectors = [$ULCollision, $UCollision, $URCollision, $LCollision, $RCollision, $DLCollision, $DCollision, $DRCollision]
	for wireDetector in wireDetectors:
		wireDetector.monitoring = false
		wireDetector.monitorable = false

func reset():
	for wireDetector in wireDetectors:
		wireDetector.monitoring = true
		wireDetector.monitorable = true
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
			elif output is baseTrigger:
				output.react()

func onWireSpriteAnimationFinished():
	if wireSprite.animation == stateToAnimString[PowerState.ON]:
		reset()

func onAdjacentConduitFound(_area_rid, area, _area_shape_index, _local_shape_index, areaDirection):
	var areaParent = area.get_parent()
	if areaParent is wire or (areaParent is electrode and area.name != "ArcDetection") or areaParent is powerTrigger or areaParent is baseTrigger:
		if !connections[areaDirection]:
			#Wires are the last conduit to have its collision enabled
			if areaParent is powerTrigger and not self in areaParent.exportConduits:
				areaParent.exportConduits.append(self)
			elif areaParent is electrode and areaParent.wireConnection != self:
				areaParent.wireConnection = self
			elif areaParent is wire and not self in connections:
				print_debug()
			connections[areaDirection] = areaParent
