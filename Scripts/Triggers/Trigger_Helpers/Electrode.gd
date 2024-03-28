extends Node2D

class_name electrode

@export var electrodeSprite: AnimatedSprite2D
@export var arcDetectionArea: Area2D
@export var lightning: lightning
@export var WireConnectionOverride : Node2D

var currState : PowerState = PowerState.OFF
var poweringConnection : Node2D
var wireConnection : Node2D
var inUseLightnings : Array[lightning]
var unusedLightnings : Array[lightning]

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
	if !WireConnectionOverride:
		wireConnection = WireConnectionOverride
	reset()

func reset():
	currState = PowerState.OFF
	electrodeSprite.animation = stateToAnimString[currState]
	poweringConnection = null
	lightning.hide()
	
func power(inputConn):
	if currState == PowerState.OFF:
		if not inputConn is electrode and not inputConn == wireConnection:
			print_debug("Unrelated wire trying to power electrode")
			return
		poweringConnection = inputConn
		currState = PowerState.ON
		electrodeSprite.animation = stateToAnimString[currState]
		electrodeSprite.play()

func outputWire():
	if wireConnection is wire:
		wireConnection.power(self)

func outputElectrode():
	var conductiveBodies = arcDetectionArea.get_overlapping_bodies()
	for cb in conductiveBodies:
		if cb == self:
			continue
		elif cb is electrode:
			
			lightning.toPos = cb
			lightning.lightning_strike()
			lightning.show()
			cb.power(self)

func onElectrodeSpriteFrameChanged():
	if electrodeSprite.frame == 3 and electrodeSprite.animation == stateToAnimString[PowerState.ON]:
		if poweringConnection is electrode:
			outputWire()
		else:
			outputElectrode()

func onElectrodeSpriteAnimationFinished():
	if electrodeSprite.animation == stateToAnimString[PowerState.ON]:
		reset()

func onAdjacentConduitFound(_area_rid, area, _area_shape_index, _local_shape_index):
	var areaParent = area.get_parent()
	if areaParent is wire or (areaParent is electrode and area.name != "ArcDetection") or areaParent is powerTrigger:
		if !wireConnection:
			wireConnection = areaParent
