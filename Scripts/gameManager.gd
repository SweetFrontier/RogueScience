class_name Main
extends Node

# Use @export to make the array editable in the inspector
@export var Levels: Array[levelController]
@export var current_level: int

@export var player: Player

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect the input event to the `_input` method.
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			# Moves player to start of current level
			player.position = Levels[current_level].get_node("Start").position
			# Resets level elements like trigger blocks
			Levels[current_level].reset()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
