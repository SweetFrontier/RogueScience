extends movingObject
class_name magneticObject

@export var arcDetectionArea: Area2D
@export var secPerStrike: float = 0.05
@export var lightningScene: PackedScene = preload("res://Scenes/Triggers/Trigger_Helpers/lightning.tscn")

var currState : PowerState = PowerState.OFF
var poweringConnection : Node2D
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
	super._ready()

func reset():
	super.reset()
	clearElectricity()

func _process(delta):
	if(makeLightning):
		secSinceStrike += delta
		if secSinceStrike >= secPerStrike:
			for l in inUseLightnings:
				l.lightning_strike()
			secSinceStrike = 0

func clearElectricity():
	currState = PowerState.OFF
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
	secSinceStrike = 0

func power(inputConn):
	if currState == PowerState.OFF:
		poweringConnection = inputConn
		currState = PowerState.ON
		conductiveBodies.clear()
		var cBodies = arcDetectionArea.get_overlapping_bodies()
		for cb in cBodies:
			if cb == self or cb == inputConn:
				continue
			elif cb is electrode or cb is magneticObject:
				if cb.currState == PowerState.ON:
					continue
				conductiveBodies.append(cb)
				var lightning = getFreeLightning()
				lightning.toPos = cb
				lightning.lightning_strike()
				makeLightning = true
				secSinceStrike = 0
				lightning.show_lightning()
				cb.power(self)

func endEnergyChain():
	clearElectricity()

func getFreeLightning():
	var freeLightning = unusedLightnings.pop_back()
	if !freeLightning:
		freeLightning = lightningScene.instantiate()
		freeLightning.fromPos = self
		freeLightning.rotation = -rotation
		add_child(freeLightning)
	inUseLightnings.append(freeLightning)
	return freeLightning	
