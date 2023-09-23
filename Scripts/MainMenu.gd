extends Control

@export var soundSettings : Control
@export var titleScreen : Control
@export var buttonSound : AudioStreamPlayer
@export var transition : AnimationPlayer

@export var musicPlayer : AudioStreamPlayer
@export var noisePlayer : AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	soundSettings.connect("close_settings", close_settings)

func close_settings() -> void:
	titleScreen.visible = true
	buttonSound.play()

func _on_start_button_pressed():
	#play sound and make music and sounds fade out
	buttonSound.play()
	musicPlayer.fadeOut()
	noisePlayer.fadeOut()
	#transition
	transition.play("SlideToBlack")
	await(transition.animation_finished)
	#change scene
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")

func _on_credits_button_pressed():
	#play sound and make music and sounds fade out
	buttonSound.play()
	musicPlayer.fadeOut()
	noisePlayer.fadeOut()
	#transition
	transition.play("SlideToBlack")
	await(transition.animation_finished)
	#change scene
	get_tree().change_scene_to_file("res://Scenes/Credits/credits.tscn")

func _on_settings_button_pressed() -> void:
	#play sound
	buttonSound.play()
	#make main menu invisible, but settings visible
	titleScreen.visible = false
	soundSettings.visible = true

func _on_quit_button_pressed():
	buttonSound.play()
	musicPlayer.fadeOut()
	noisePlayer.fadeOut()
	#transition
	transition.play("SlideToBlack")
	await(transition.animation_finished)
	get_tree().quit()
