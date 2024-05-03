extends Node

class_name levelController

@export var cameraSpot : Marker2D
@export var cameraSize : Vector2
@export var player : rigidPlayer
@export var transitionField : TransitionField
@export var theBoss: boss
@export var sequencePlayer : AnimationPlayer
@export var introAnimationName : String
@export var endAnimationName : String

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
	#If running independently, restart the level to begin
	if get_tree().get_root() == get_parent():
		reset()
		if theBoss != null:
			player.get_node("Camera2D").enabled = true
	else:
		player.hide()
	
	if theBoss != null:
		transitionField.connect("start_end_sequence", startEndSequence)
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
		player.get_node("Camera2D").enabled = true
	if sequencePlayer != null:
		sequencePlayer.stop()
		sequencePlayer.play(introAnimationName)

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

func startSequence(animationName):
	sequencePlayer.play(animationName)

func startEndSequence():
	sequencePlayer.play(endAnimationName)

func callSequence(body, animationName):
	if not body is rigidPlayer:
		return
	startSequence(animationName)
