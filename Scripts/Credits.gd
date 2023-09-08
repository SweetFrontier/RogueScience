extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.y += delta*50
	if (position.y > 3450):
		get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
