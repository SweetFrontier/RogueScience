extends Control

@export var soundSettings : Control
@export var titleScreen : Control

# Called when the node enters the scene tree for the first time.
func _ready():
	soundSettings.connect("close_settings", close_settings)

func close_settings() -> void:
	titleScreen.visible = true

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")

func _on_credits_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Credits/credits.tscn")

func _on_settings_button_pressed() -> void:
	titleScreen.visible = false
	soundSettings.visible = true

func _on_quit_button_pressed():
	get_tree().quit()
