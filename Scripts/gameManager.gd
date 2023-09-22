class_name Main
extends Node

# Use @export to make the array editable in the inspector
@export var Levels: Array[levelController]
@export var camera: Camera2D
@export var current_level: int
@export var musicPlayer: AudioStreamPlayer

var moving : bool = false
var movingTime : float = 1
var movingProgress : float = 0
var movingStart : Vector2
var movingGoal : Vector2
var zooming : bool = false
var zoomingTime : float = 1
var zoomingProgress : float = 0
var zoomingStart : Vector2
var zoomingGoal : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Levels[current_level].process_mode = Node.PROCESS_MODE_ALWAYS
	var min_zoom_size : Vector2 =  Levels[current_level].cameraSize
	var final_zoom_size = minf(1280/min_zoom_size.x,736/min_zoom_size.y)
	camera.global_position = Levels[current_level].cameraSpot.global_position
	camera.zoom = Vector2(final_zoom_size,final_zoom_size)
	#movingStart = camera.global_position
	#movingGoal = Levels[current_level].cameraSpot.global_position
	#var min_zoom_size : Vector2 =  Levels[current_level].cameraSize
	#var final_zoom_size = minf(1280/min_zoom_size.x,736/min_zoom_size.y)
	#zoomingStart = camera.zoom
	#zoomingGoal = Vector2(final_zoom_size,final_zoom_size)
	set_process(true)
	for level in Levels:
		level.transitionField.connect("increase_level_signal", increase_level)

func _process(delta):
	if (moving):
		movingProgress += delta
		var move_time = smoothstep(0,1,movingProgress/movingTime)
		var smooth_move_x = lerp(movingStart.x, movingGoal.x, move_time)
		var smooth_move_y = lerp(movingStart.y, movingGoal.y, move_time)
		camera.position = Vector2(smooth_move_x,smooth_move_y)
		if movingProgress >= movingTime:
			camera.position = movingGoal
			moving = false
		
	if (zooming):
		zoomingProgress += delta
		var zoom_time = smoothstep(0,1,zoomingProgress/zoomingTime)
		var smooth_zoom_x = lerp(zoomingStart.x, zoomingGoal.x, zoom_time)
		var smooth_zoom_y = lerp(zoomingStart.y, zoomingGoal.y, zoom_time)
		camera.set_zoom(Vector2(smooth_zoom_x, smooth_zoom_y))
		if zoomingProgress >= zoomingTime:
			camera.set_zoom(zoomingGoal)
			zooming = false

	if (not(moving or zooming)):
		Levels[current_level-1].process_mode = Node.PROCESS_MODE_DISABLED
		Levels[current_level].process_mode = Node.PROCESS_MODE_PAUSABLE

func increase_level() -> void:
	current_level += 1
	if(current_level >= Levels.size()):
		get_tree().change_scene_to_file("res://Scenes/Credits/credits.tscn")
		return
	moving = true
	movingProgress = 0
	movingStart = camera.global_position
	movingGoal = Levels[current_level].cameraSpot.global_position
	zooming = true
	zoomingProgress = 0
	zoomingStart = camera.zoom
	var min_zoom_size : Vector2 =  Levels[current_level].cameraSize
	var final_zoom_size = minf(1280/min_zoom_size.x,736/min_zoom_size.y)
	zoomingGoal = Vector2(final_zoom_size,final_zoom_size)
	# set music
	if (current_level == 2):
		musicPlayer.changeMusic("midlevels");
	elif (current_level == 4):
		musicPlayer.changeMusic("intense");

func resetLevel() -> void:
	# Resets the entire current level
	Levels[current_level].reset()
	get_tree().paused = false

#wat? player_death? no restart? nah. ima do my own thing.
func player_death() -> void:
	$PauseMenu/VBoxContainer.visible = true
	$PauseMenu/VBoxContainer/ResumeButton.disabled = true
	$PauseMenu/DeathImage.visible = true
	$PauseMenu/AnimatedSprite2D.visible = false
	get_tree().paused = !get_tree().paused
