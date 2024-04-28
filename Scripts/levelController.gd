extends Node

class_name levelController

@export var cameraSpot : Marker2D
@export var cameraSize : Vector2
@export var player : rigidPlayer
@export var transitionField : TransitionField
@export var DEBUG_MODE: bool = false
@export var theBoss: boss
@export var sequencePlayer : AnimationPlayer

var triggerBlocks : Array[baseTrigger]
var movingObjects : Array[movingObject]
var wires : Array[wire]
var electrodes : Array[electrode]
var magnetTriggers : Array[magnetTrigger]
var magneticMovingObjects : Array[movingObject]
var remainingTriggerBlocks : Array[baseTrigger]
var availableKeys : Array
var isCurrentLevel : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var children = get_children()
	var index = 0
	while index < children.size():
		var child = children[index]
		if child is baseTrigger:
			child.hide_key()
			triggerBlocks.append(child)
			child.connect("remove_key_signal", remove_key)
			child.connect("randomize_block_keys_signal", randomize_block_keys)
			if child is magnetTrigger:
				magnetTriggers.append(child)
		elif child is movingObject:
			child.hide()
			movingObjects.append(child)
			if player != null:
				child.setPlayer(player)
			if child.magnetic:
				magneticMovingObjects.append(child)
				for grandchild in child.get_children():
					if grandchild is fellaBoxTrigger:
						triggerBlocks.append(grandchild)
						grandchild.connect("remove_key_signal", remove_key)
						grandchild.connect("randomize_block_keys_signal", randomize_block_keys)
		elif child is wire:
			wires.append(child)
		elif child is electrode:
			electrodes.append(child)
		elif child is triggerHolder:
			children.append_array(child.get_children())
		index += 1
	if (DEBUG_MODE):
		reset()
	else:
		player.hide()
	#Give each Magnetic Moving Object a reference to each Magnet in the scene
	for magneticObject in magneticMovingObjects:
		magneticObject.magnetTriggers = magnetTriggers.duplicate()

func reset():
	isCurrentLevel = true
	availableKeys = range(48,58)+range(65,91)
	remainingTriggerBlocks = triggerBlocks.duplicate(true)
	for block in triggerBlocks:
		block.reset()
		randomize_block_keys()
	for moveO in movingObjects:
		moveO.show()
		moveO.reset()
	for e in electrodes:
		e.reset()
	for w in wires:
		w.reset()
	player.reset()
	#show the player
	player.show()
	if theBoss != null:
		theBoss.reset()
	if sequencePlayer != null:
		sequencePlayer.stop()
		sequencePlayer.play("1-10_BossIntro")

func levelEnded():
	isCurrentLevel = false
	player.queue_free();
	for child in triggerBlocks:
		child.hide_key()
		if child is breakableBlocks:
			child.explodeable_polygon.reset();
		elif child is invisibleBlock:
			child.implodeable_polygon.reset();

func remove_key(caller:baseTrigger,keyNum:int):
	availableKeys.remove_at(availableKeys.find(keyNum));
	remainingTriggerBlocks.remove_at(remainingTriggerBlocks.find(caller))

func randomize_block_keys():
	availableKeys.shuffle()
	for i in range(remainingTriggerBlocks.size()):
		remainingTriggerBlocks[i].set_button(availableKeys[i])
