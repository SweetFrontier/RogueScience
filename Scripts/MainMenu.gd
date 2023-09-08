extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")	


func _on_credits_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/credits.tscn")


func _on_quit_button_pressed():
	get_tree().quit()
