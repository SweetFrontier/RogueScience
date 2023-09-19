extends Control

@onready var main = get_tree().root.get_node("Main")

func _on_start_button_pressed():
	$VBoxContainer.visible = false
	get_tree().paused = false

func _on_restart_button_pressed():
	$VBoxContainer.visible = false
	$DeathImage.visible = false
	$AnimatedSprite2D.visible = true
	$VBoxContainer/ResumeButton.disabled = false
	main.resetLevel()

func _on_settings_button_pressed() -> void:
	get_parent().get_node("OptionsMenu").visible = true
	visible = false

func _on_quit_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Screens/MainMenu.tscn")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and !event.is_echo():
		if event.keycode == KEY_ESCAPE and !$VBoxContainer/ResumeButton.disabled:
			if event.pressed:
				$AnimatedSprite2D.frame = 1
				$VBoxContainer.visible = !$VBoxContainer.visible
				get_tree().paused = !get_tree().paused
			else:
				$AnimatedSprite2D.frame = 0
		if event.keycode == KEY_QUOTELEFT and event.pressed:
			_on_restart_button_pressed()
