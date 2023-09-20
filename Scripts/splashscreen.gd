extends Control

@export var splashscreenVideo : VideoStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_video_stream_player_finished():
	get_tree().change_scene_to_file("res://Scenes/Screens/MainMenu.tscn")
	pass # Replace with function body.
