extends Control

@export var transitionToBlack : AnimationPlayer
@export var buttonSound : AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_animation_player_animation_finished(anim_name):
	get_tree().change_scene_to_file("res://Scenes/Other/splashscreen.tscn")

func _input(event : InputEvent):
	if (event is InputEventKey and event.keycode == KEY_ESCAPE) or (event is InputEventMouseButton and event.is_double_click()):
			transitionToBlack.play("FadeToBlack")
			buttonSound.play()
			await transitionToBlack.animation_finished
			get_tree().change_scene_to_file("res://Scenes/Other/splashscreen.tscn")

