class_name Main
extends Node

# Use @export to make the array editable in the inspector
@export var Levels: Array[levelController]
@export var current_level: int

@export var player: Player

func resetLevel() -> void:
	# Moves player to start of current level
	$baseLevel/Player.position = Levels[current_level].get_node("Start").position
	# Resets level elements like trigger blocks
	Levels[current_level].reset()
	get_tree().paused = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
