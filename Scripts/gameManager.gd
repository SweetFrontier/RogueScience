class_name Main
extends Node

# Use @export to make the array editable in the inspector
@export var Levels: Array[levelController]
@export var camera: Camera2D
@export var current_level: int
@export var pauseMenu : Control
@export var musicPlayer: AudioStreamPlayer
@export var Transition : AnimatedSprite2D
@export var resetWipeTransition : AnimationPlayer
@export var resetWipeTransitionContoller : ColorRect
@export var deathTimerForReset : float = 1

var moving : bool = true
var movingTime : float = 1
var movingProgress : float = 0
var movingStart : Vector2
var movingGoal : Vector2
var zooming : bool = true
var zoomingTime : float = 1
var zoomingProgress : float = 0
var zoomingStart : Vector2
var zoomingGoal : Vector2
var deathTimer : float = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resetWipeTransitionContoller.connect("screenCovered", screen_wipe_covered)
	movingStart = camera.global_position
	movingGoal = Levels[current_level].cameraSpot.global_position
	var min_zoom_size : Vector2 =  Levels[current_level].cameraSize
	var final_zoom_size = minf(1280/min_zoom_size.x,736/min_zoom_size.y)
	zoomingStart = camera.zoom
	zoomingGoal = Vector2(final_zoom_size,final_zoom_size)
	set_process(true)
	for level in Levels:
		level.transitionField.connect("increase_level_signal", increase_level)
		level.player.connect("player_death_signal", player_death)
	await(resetWipeTransition.animation_finished)
	Levels[current_level].process_mode = Node.PROCESS_MODE_PAUSABLE
	pauseMenu.set_pausability(true)

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
	
	#this seems kinda unoptimized but it works
	#if (Transition.animation_finished):
		#Levels[current_level-1].process_mode = Node.PROCESS_MODE_DISABLED
		#Levels[current_level].process_mode = Node.PROCESS_MODE_PAUSABLE
	
	if (deathTimer >= 0):
		deathTimer += delta
		if (deathTimer > deathTimerForReset):
			deathTimer = -2 #death timer being -2 means just died
			resetWipeTransitionContoller.cover_screen()

func increase_level() -> void:
	#Next level
	current_level += 1
	if(current_level >= Levels.size()):
		pauseMenu.set_pausability(false)
		musicPlayer.fadeOut()
		resetWipeTransitionContoller.cover_screen()
		return
	#moving = true
	#movingProgress = 0
	#movingStart = camera.global_position
	#movingGoal = Levels[current_level].cameraSpot.global_position
	#zooming = true
	#zoomingProgress = 0
	#zoomingStart = camera.zoom
	var min_zoom_size : Vector2 =  Levels[current_level].cameraSize
	var final_zoom_size = minf(1280/min_zoom_size.x,736/min_zoom_size.y)
	#zoomingGoal = Vector2(final_zoom_size,final_zoom_size)
	
	pauseMenu.set_pausability(false)
	
	Transition.show()
	Transition.play("CoverScreen")
	Transition.get_child(0).play()
	
	await(Transition.animation_finished)
	
	#freeze prev level
	Levels[current_level-1].process_mode = Node.PROCESS_MODE_DISABLED
	
	#move camera and change zoom
	camera.position = Levels[current_level].cameraSpot.global_position
	camera.set_zoom(Vector2(final_zoom_size, final_zoom_size))
	Levels[current_level-1].levelEnded()
	
	#uncover screen
	Transition.play("UncoverScreen");
	
	# set music
	if (current_level == 2):
		musicPlayer.changeMusic("midlevels");
	elif (current_level == 4):
		musicPlayer.changeMusic("intense");
	
	await(Transition.animation_finished)
	Transition.hide()
	Levels[current_level].process_mode = Node.PROCESS_MODE_PAUSABLE
	pauseMenu.set_pausability(true)

func resetLevel() -> void:
	# Resets the entire current level
	Levels[current_level].reset()
	get_tree().paused = false

func player_death() -> void:
	deathTimer = 0
	pauseMenu.set_pausability(false)

func screen_wipe_covered():
	if (deathTimer == -2):
		deathTimer = -1 #reset to -1
		resetLevel()
		resetWipeTransitionContoller.uncover_screen()
		pauseMenu.set_pausability(true)
	if (current_level >= Levels.size()):
		get_tree().change_scene_to_file("res://Scenes/Credits/credits.tscn")
		pauseMenu.set_pausability(false)
