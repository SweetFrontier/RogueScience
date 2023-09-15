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
	for level in Levels:
		level.transitionField.connect("increase_level_signal", increase_level)

func _process(delta):
	if (moving):
		# Smooth movement towards new level center
		var final_pos : Vector2 = Levels[current_level].cameraSpot.global_position
		var smooth_move_x = lerp(camera.position.x, final_pos.x, 3 * delta)
		var smooth_move_y = lerp(camera.position.y, final_pos.y, 3 * delta)
		if abs(smooth_move_x - final_pos.x) > 1 or abs(smooth_move_y - final_pos.y) > 1:
			camera.position = Vector2(smooth_move_x, smooth_move_y)
		else:
			camera.position = final_pos
			moving = false
		
	if (zooming):
		var final_zoom : Vector2 =  Levels[current_level].cameraSize
		final_zoom.x = 1280/final_zoom.x
		final_zoom.y = 736/final_zoom.y
		var smooth_zoom_x = lerp(camera.zoom.x, final_zoom.x, 3 * delta)
		var smooth_zoom_y = lerp(camera.zoom.y, final_zoom.y, 3 * delta)
		if abs(smooth_zoom_x - final_zoom.x) > 0.01 or abs(smooth_zoom_y - final_zoom.y) > 0.01:
			camera.set_zoom(Vector2(smooth_zoom_x, smooth_zoom_y))
		else:
			camera.set_zoom(final_zoom)
			zooming = false

	if (not(moving or zooming)):
		Levels[current_level-1].process_mode = Node.PROCESS_MODE_DISABLED
		Levels[current_level].process_mode = Node.PROCESS_MODE_ALWAYS

func increase_level() -> void:
	current_level += 1
	if(current_level >= Levels.size()):
		get_tree().change_scene_to_file("res://Scenes/Credits/credits.tscn")
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
