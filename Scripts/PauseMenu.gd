extends Control

@onready var main = get_tree().root.get_node("Main")
@onready var optionsMenu : Control = get_parent().get_node("OptionsMenu")
@onready var sound : AudioStreamPlayer = get_parent().get_node("ButtonSound")

func _ready():
	optionsMenu.connect("close_settings", close_sound_settings)

func _on_start_button_pressed():
	sound.play()
	$VBoxContainer.visible = false
	get_tree().paused = false

func _on_restart_button_pressed():
	sound.play()
	$VBoxContainer.visible = false
	$DeathImage.visible = false
	$AnimatedSprite2D.visible = true
	$VBoxContainer/ResumeButton.disabled = false
	main.resetLevel()

func _on_settings_button_pressed() -> void:
	sound.play()
	optionsMenu.visible = true
	visible = false

func _on_quit_button_pressed():
	sound.play()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Screens/MainMenu.tscn")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and !event.is_echo():
		if event.keycode == KEY_ESCAPE and !$VBoxContainer/ResumeButton.disabled:
			if event.pressed:
				sound.play()
				$AnimatedSprite2D.frame = 1
				$VBoxContainer.visible = !$VBoxContainer.visible
				get_tree().paused = !get_tree().paused
				
				#if unpausing then close the optionsmenu and open this menu for the next time paused
				if (!get_tree().paused):
					visible = true
					optionsMenu.visible = false
			else:
				$AnimatedSprite2D.frame = 0
		if event.keycode == KEY_QUOTELEFT and event.pressed:
			_on_restart_button_pressed()

func close_sound_settings():
	sound.play()
	visible = true
