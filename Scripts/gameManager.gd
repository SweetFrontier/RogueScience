class_name Main
extends Node

# Use @export to make the array editable in the inspector
@export var Levels: Array[levelController]
@export var camera: Camera2D
@export var current_level: int

func resetLevel() -> void:
	# Resets the entire current level
	Levels[current_level].reset()
	get_tree().paused = false

func player_death() -> void:
	$PauseMenu/VBoxContainer.visible = true
	$PauseMenu/VBoxContainer/ResumeButton.disabled = true
	$PauseMenu/DeathImage.visible = true
	$PauseMenu/AnimatedSprite2D.visible = false
	get_tree().paused = !get_tree().paused
