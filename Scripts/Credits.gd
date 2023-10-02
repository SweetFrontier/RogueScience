extends Control



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.y += delta*53
	if (position.y > 3650):
		get_tree().change_scene_to_file("res://Scenes/Screens/MainMenu.tscn")


func _on_skip_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Screens/MainMenu.tscn")
