class_name Main
extends Node

# Use @export to make the array editable in the inspector
@export var Levels: Array[levelController]
@export var camera: Camera2D
@export var current_level: int

var moving : bool = true
var zooming : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Levels[current_level].process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(true)

func _process(delta):
	if (moving):
		# If you move to a new level start that level
		Levels[current_level-1].process_mode = Node.PROCESS_MODE_DISABLED
		Levels[current_level].process_mode = Node.PROCESS_MODE_ALWAYS
		# Smooth movement towards new level center
		var final_pos : Vector2 = Levels[current_level].cameraSpot.global_position
		var smooth_move_x = lerp(camera.position.x, final_pos.x, 3 * delta)
		var smooth_move_y = lerp(camera.position.y, final_pos.y, 3 * delta)
		if (smooth_move_x != final_pos.x or smooth_move_y != final_pos.y):
			camera.position = Vector2(smooth_move_x, smooth_move_y)
		else:
			moving = false
		
	if (zooming):
		var final_zoom : Vector2 =  Levels[current_level].cameraSize
		var smooth_zoom_x = lerp(camera.zoom.x, 1280/final_zoom.x, 3 * delta)
		var smooth_zoom_y = lerp(camera.zoom.y, 736/final_zoom.y, 3 * delta)
		if smooth_zoom_x != final_zoom.x or smooth_zoom_y != final_zoom.y:
			camera.set_zoom(Vector2(smooth_zoom_x, smooth_zoom_y))
		else:
			zooming = false

func increase_level() -> void:
	current_level += 1
	moving = true
	zooming = true

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
