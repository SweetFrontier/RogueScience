extends Node

class_name levelController

@export var triggerBlocks : Array[baseTrigger]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func reset():
	for block in triggerBlocks:
		block.reset()
		randomize_block_keys()

func randomize_block_keys():
	for block in triggerBlocks:
		#Get value for 36 possible keys
		var rand = randi_range(0,35)
		#Since there are 7 keycodes between number and letter keys
		if(rand > 9):
			rand += 7
		block.set_button(48+rand)
	pass
