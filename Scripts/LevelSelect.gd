extends Control

@export var transition : AnimationPlayer
@export var buttonSounds : AudioStreamPlayer
@export var levelButtons : Array[TextureButton]

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in levelButtons.size():
		if (i > GlobalVariables.unlockedLevel):
			levelButtons[i].hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_level_button_pressed(level):
	buttonSounds.play()
	transition.play("FadeToBlack")
	GlobalVariables.currentLevel = level
	await transition.animation_finished
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")


func _on_return_button_pressed():
	buttonSounds.play()
	transition.play("FadeToBlack")
	await transition.animation_finished
	get_tree().change_scene_to_file("res://Scenes/Screens/MainMenu.tscn")
