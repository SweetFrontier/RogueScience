extends Node2D

class_name electrode

@export var electrodeSprite: AnimatedSprite2D
@export var arcDetectionArea: Area2D
@export var WireConnectionOverride : Node2D
@export var secPerStrike: float = 0.05
@export var lightningScene: PackedScene

var currState : PowerState = PowerState.OFF
var poweringConnection : Node2D
var wireConnection : Node2D
var makeLightning : bool = false
var secSinceStrike : float = 0
var inUseLightnings : Array[lightningBolt]
var unusedLightnings : Array[lightningBolt]
var conductiveBodies : Array[Node2D]

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
	for cb in conductiveBodies:
		if cb is magneticObject:
			cb.endEnergyChain()
	conductiveBodies.clear()
	for l in inUseLightnings:
		l.hide_lightning()
		unusedLightnings.append(l)
	inUseLightnings.clear()
	makeLightning = false

func _process(delta):
	if(makeLightning):
		secSinceStrike += delta
		if secSinceStrike >= secPerStrike:
			for l in inUseLightnings:
				l.lightning_strike()
			secSinceStrike = 0

func power(inputConn):
	if currState == PowerState.OFF:
		if not inputConn is electrode and not inputConn is magneticObject and not inputConn == wireConnection:
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
	conductiveBodies = arcDetectionArea.get_overlapping_bodies()
	var cBodies = arcDetectionArea.get_overlapping_bodies()
	for cb in cBodies:
		if cb == self or (cb is magneticObject and cb.currState == PowerState.ON):
			continue
		elif cb is electrode or cb is magneticObject:
			conductiveBodies.append(cb)
			var lightning = getFreeLightning()
			lightning.toPos = cb
			lightning.lightning_strike()
			makeLightning = true
			secSinceStrike = 0
			lightning.show_lightning()
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

func getFreeLightning():
	var freeLightning = unusedLightnings.pop_back()
	if !freeLightning:
		freeLightning = lightningScene.instantiate()
		freeLightning.fromPos = self
		add_child(freeLightning)
	inUseLightnings.append(freeLightning)
	return freeLightning	
