extends Node

class_name levelController

@export var cameraSpot : Marker2D

var triggerBlocks : Array[baseTrigger]
var movingObjects : Array[movingObject]
var player : Player
var remainingTriggerBlocks : Array[baseTrigger]
var availableKeys : Array
# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child is baseTrigger:
			triggerBlocks.append(child)
			child.connect("remove_key_signal", remove_key)
			child.connect("randomize_block_keys_signal", randomize_block_keys)
		elif child is movingObject:
			movingObjects.append(child)
		elif child is Player:
			player = child
	reset()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func reset():
	availableKeys = range(48,58)+range(65,91)
	remainingTriggerBlocks = triggerBlocks.duplicate(true)
	for block in triggerBlocks:
		block.reset()
		randomize_block_keys()
	for moveO in movingObjects:
		moveO.reset()
	player.reset()

func remove_key(caller:baseTrigger,keyNum:int):
	availableKeys.remove_at(availableKeys.find(keyNum));
	remainingTriggerBlocks.remove_at(remainingTriggerBlocks.find(caller))

func randomize_block_keys():
	availableKeys.shuffle()
	for i in range(remainingTriggerBlocks.size()):
		remainingTriggerBlocks[i].set_button(availableKeys[i])
