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

func _on_quit_button_pressed():
	get_tree().quit()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and !event.is_echo() and !$VBoxContainer/ResumeButton.disabled:
		if event.keycode == KEY_ESCAPE:
			if event.pressed:
				$AnimatedSprite2D.frame = 1
				$VBoxContainer.visible = !$VBoxContainer.visible
				get_tree().paused = !get_tree().paused
			else:
				$AnimatedSprite2D.frame = 0
