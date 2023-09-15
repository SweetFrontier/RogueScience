extends Control

@export var volume = 10


func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value)


func _on_pause_menu_pressed() -> void:
	if (get_tree().current_scene.name == "Main"):
		get_parent().get_node("PauseMenu").visible = true
	else:
		get_tree().change_scene_to_file("res://Scenes/Screens/MainMenu.tscn")
	visible = false
	
