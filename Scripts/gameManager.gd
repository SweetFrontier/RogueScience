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

func player_death() -> void:
	$PauseMenu/VBoxContainer.visible = true
	$PauseMenu/VBoxContainer/ResumeButton.disabled = true
	$PauseMenu/DeathImage.visible = true
	$PauseMenu/AnimatedSprite2D.visible = false
	get_tree().paused = !get_tree().paused
