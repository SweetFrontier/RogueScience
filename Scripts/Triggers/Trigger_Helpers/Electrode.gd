extends Node2D

class_name electrode

@export var electrodeSprite: AnimatedSprite2D
@export var arcDetectionArea: Area2D
@export var WireConnectionOverride : Node2D
@export var secPerStrike: float = 0.05
@export var startLocked: bool = false
@export var one_shot: bool = false
@export var lightningScene: PackedScene
@export var Sound: AudioStreamPlayer2D

signal striking

var currState : PowerState = PowerState.OFF
var poweringConnection : Node2D
var wireConnection : Node2D
var makeLightning : bool = false
var secSinceStrike : float = 0
var inUseLightnings : Array[lightningBolt]
var unusedLightnings : Array[lightningBolt]
var conductiveBodies : Array[Node2D]

var locked = false
var activated = false

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

func _ready():
	if !wireConnection:
		wireConnection = WireConnectionOverride
	$WireDetection.monitoring = false
	$WireDetection.monitorable = false
	$ArcDetection.monitoring = false
	$ArcDetection.monitorable = false

func reset():
	$WireDetection.monitoring = true
	$WireDetection.monitorable = true
	$ArcDetection.monitoring = true
	$ArcDetection.monitorable = true
	
	activated = false
	clearElectricity()
	
	locked = false
	if startLocked:
		lock()

func clearElectricity():
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
	activated = true
	if currState == PowerState.OFF:
		if not inputConn is electrode and not inputConn is magneticObject and not inputConn is boss and not inputConn == wireConnection:
			print_debug("Unrelated wire trying to power electrode")
			return
		poweringConnection = inputConn
		currState = PowerState.ON
		electrodeSprite.animation = stateToAnimString[currState]
		electrodeSprite.play()

func outputWire():
	if wireConnection is wire or wireConnection is electrode:
		wireConnection.power(self)
	elif wireConnection is baseTrigger:
		wireConnection.react()

func outputElectrode():
	conductiveBodies = arcDetectionArea.get_overlapping_bodies()
	var cBodies = arcDetectionArea.get_overlapping_bodies()
	for cb in cBodies:
		if cb == self:
			continue
		elif cb is electrode or cb is magneticObject:
			if cb.currState == PowerState.ON or (cb is electrode and (cb.locked or (cb.activated and cb.one_shot))):
				continue
			conductiveBodies.append(cb)
			var lightning = getFreeLightning()
			lightning.toPos = cb
			lightning.lightning_strike()
			makeLightning = true
			secSinceStrike = 0
			lightning.show_lightning()
			cb.power(self)
			Sound.play()
			#emit_signal("striking")

func onElectrodeSpriteFrameChanged():
	if electrodeSprite.animation == stateToAnimString[PowerState.ON]:
		if electrodeSprite.frame == 3:
			if (poweringConnection is electrode and wireConnection != poweringConnection) or poweringConnection is magneticObject or poweringConnection is boss:
				outputWire()
			else:
				outputElectrode()

func onElectrodeSpriteAnimationFinished():
	if electrodeSprite.animation == stateToAnimString[PowerState.ON]:
		clearElectricity()

func onAdjacentConduitFound(_area_rid, area, _area_shape_index, _local_shape_index):
	var areaParent = area.get_parent()
	if areaParent is wire or (areaParent is electrode and area.name != "ArcDetection") or areaParent is powerTrigger or areaParent is baseTrigger:
		if !wireConnection:
			#electrodes will only be able to detect other powerTriggers, baseTriggers or other eledtrodes, as it has its collision turned on second
			if areaParent is powerTrigger and not self in areaParent.exportConduits:
				areaParent.exportConduits.append(self)
			elif areaParent is baseTrigger:
				areaParent.show_button = false
				areaParent.TriggerKeySprite.modulate.a = 0
			elif areaParent is electrode and areaParent.wireConnection != self:
				areaParent.wireConnection = self
			wireConnection = areaParent

func getFreeLightning():
	var freeLightning = unusedLightnings.pop_back()
	if !freeLightning:
		freeLightning = lightningScene.instantiate()
		freeLightning.fromPos = self
		freeLightning.rotation = -rotation
		add_child(freeLightning)
	inUseLightnings.append(freeLightning)
	return freeLightning	

func lock():
	locked = true

func unlock():
	locked = false
