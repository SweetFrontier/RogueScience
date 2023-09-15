extends Control

signal close_settings

@export var volume = 10
@export var soundSlider : HSlider
@export var musicSlider : HSlider

func _ready():
	#make music and sound variables
	var musicVolume : float = AudioServer.get_bus_volume_db(2)
	var soundVolume : float = AudioServer.get_bus_volume_db(1)
	#set to music and sound variables iff not null
	if (musicVolume != null):
		musicSlider.value = (db_to_linear(musicVolume))
	if (soundVolume != null):
		soundSlider.value = (db_to_linear(soundVolume))

func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(2, linear_to_db(value))

func _on_h_slider_2_value_changed(value: float):
	AudioServer.set_bus_volume_db(1, linear_to_db(value))

func _on_pause_menu_pressed() -> void:
	if (get_tree().current_scene.name == "Main"):
		get_parent().get_node("PauseMenu").visible = true
	else:
		emit_signal("close_settings")
	visible = false

