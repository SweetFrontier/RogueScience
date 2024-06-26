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

var musicChangePoints = [10, 14, 20, 30]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	#Set the number of levels in the game to be the number of numbers in Main
	GlobalVariables.numLevels = Levels.size()
	
	#set current level to global current level
	#REMOVE THIS IF STATEMENT BEFORE UPLOAD TO ITCH. THIS IS FOR DEBUGGING PURPOSES ONLY
	if current_level < 1:
		current_level = GlobalVariables.currentLevel-1
	#set music
	if (current_level % 10 == 9):
		#boss level
		var bossy = clamp(int((current_level+1) / 10), 1, 4)
		musicPlayer.changeMusic("boss"+str(bossy));
	elif (current_level < musicChangePoints[0]):
		musicPlayer.set_stream(load("res://Sounds/Music/puzzle(calm).ogg"))
	elif (current_level < musicChangePoints[1]):
		musicPlayer.set_stream(load("res://Sounds/Music/puzzle(midlevels).ogg"))
	elif (current_level < musicChangePoints[2]):
		musicPlayer.set_stream(load("res://Sounds/Music/puzzle(intense).ogg"))
	elif (current_level < musicChangePoints[3]):
		musicPlayer.set_stream(load("res://Sounds/Music/puzzle(act_three).ogg"))
	else:
		musicPlayer.set_stream(load("res://Sounds/Music/puzzle(act_four).ogg"))
	#play music
	musicPlayer.play()
	
	resetWipeTransitionContoller.connect("screenCovered", screen_wipe_covered)
	#movingStart = camera.global_position
	#movingGoal = Levels[current_level].cameraSpot.global_position
	current_level = clamp(current_level, 0, GlobalVariables.numLevels-1)
	#resetLevel()
	movingGoal = Levels[current_level].cameraSpot.global_position
	movingStart = movingGoal
	var min_zoom_size : Vector2 =  Levels[current_level].cameraSize
	var final_zoom_size = minf(1280/min_zoom_size.x,736/min_zoom_size.y)
	#zoomingStart = camera.zoom
	#zoomingGoal = Vector2(final_zoom_size,final_zoom_size)
	zoomingGoal = Vector2(final_zoom_size,final_zoom_size)
	zoomingStart = zoomingGoal
	set_process(true)
	for level in Levels:
		level.transitionField.connect("increase_level_signal", increase_level)
		level.player.connect("player_death_signal", player_death)
	#await(resetWipeTransition.animation_finished)
	Levels[current_level].process_mode = Node.PROCESS_MODE_PAUSABLE
	resetLevel()
	await(resetWipeTransition.animation_finished)
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
	
	if (deathTimer >= 0):
		deathTimer += delta
		if (deathTimer > deathTimerForReset):
			deathTimer = -2 #death timer being -2 means just died
			resetWipeTransitionContoller.cover_screen()

func increase_level() -> void:
	#tell player to be silent
	Levels[current_level].player.won_level_silence()
	#Next level
	current_level += 1
	GlobalVariables.currentLevel = current_level+1
	#set global unlocked levels to up to this one
	if (GlobalVariables.unlockedLevel < current_level):
		GlobalVariables.unlockedLevel = current_level
		GlobalVariables.give_free_cookies()
	Transition.modulate = Color(1,1,1)
	if(current_level == Levels.size()-1):
		pauseMenu.set_pausability(false)
		#musicPlayer.fadeOut()
		Transition.modulate = Color(4,1.5,1)
		
		#GlobalVariables.finishedTheGame = true
		
		#Transition.show()
		#Transition.play("CoverScreen")
		#Transition.get_child(0).play()
		
		#await(Transition.animation_finished)
		#screen_wipe_covered()
		#resetWipeTransitionContoller.cover_screen()
		#return
	elif (current_level >= Levels.size()):
		pauseMenu.set_pausability(false)
		musicPlayer.fadeOut()
		resetWipeTransitionContoller.cover_screen()
		return
	var min_zoom_size : Vector2 =  Levels[current_level].cameraSize
	var final_zoom_size = minf(1280/min_zoom_size.x,736/min_zoom_size.y)
	
	pauseMenu.set_pausability(false)
	
	#Transition.modulate = Color(1,1,1)
	Transition.show()
	Transition.play("CoverScreen")
	Transition.get_child(0).play()
	
	await(Transition.animation_finished)
	
	#tell prev leve it ended
	Levels[current_level-1].levelEnded()
	
	#freeze prev level
	Levels[current_level-1].process_mode = Node.PROCESS_MODE_DISABLED
	
	#If prev level was a boss level, regain control of the camera
	if Levels[current_level-1].theBoss != null:
		camera.enabled = true
		Levels[current_level-1].player.get_node("Camera2D").enabled = false
	
	#move camera and change zoom
	camera.position = Levels[current_level].cameraSpot.global_position
	camera.set_zoom(Vector2(final_zoom_size, final_zoom_size))
	
	# set music
	if (current_level % 10 == 9):
		#boss level
		var bossy = clamp(int((current_level+1) / 10), 1, 4)
		musicPlayer.changeMusic("boss"+str(bossy));
	elif (current_level == musicChangePoints[0]):
		musicPlayer.changeMusic("midlevels");
	elif (current_level == musicChangePoints[1]):
		musicPlayer.changeMusic("intense");
	elif (current_level == musicChangePoints[2]):
		musicPlayer.changeMusic("act_three");
	elif (current_level == musicChangePoints[3]):
		musicPlayer.changeMusic("act_four");
	
	Levels[current_level].process_mode = Node.PROCESS_MODE_PAUSABLE
	pauseMenu.set_pausability(true)
	resetLevel()
	#Levels[current_level].reset()
	
	#uncover screen
	Transition.play("UncoverScreen");
	await(Transition.animation_finished)
	Transition.hide()

func resetLevel() -> void:
	#If the level is a boss level, relinquish control of the camera
	if Levels[current_level].theBoss != null:
		camera.enabled = false
		Levels[current_level].player.get_node("Camera2D").enabled = true
	else:
		camera.enabled = true
	
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

func _input(event):
	# Check if the associated button is pressed and the trigger is active.
	if event is InputEventKey and event.is_released() and event.shift_pressed:
		if event.keycode == KEY_PERIOD:
			increase_level()

func fadeOutMusic():
	musicPlayer.fadeOut()
	
func fadeInMusic():
	musicPlayer.fadeIn()
