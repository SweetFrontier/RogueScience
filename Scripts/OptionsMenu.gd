extends Control


signal close_settings

@export var sound_slider_stop_time := 0.5
@export var soundSlider : HSlider
@export var soundPlayer : AudioStreamPlayer
@export var musicSlider : HSlider

#settingUp variable so when loading, doesn't play sounds
var settingUp : bool = true
var timer : float = 0

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
	if (settingUp):
		settingUp = false
	else:
		timer = sound_slider_stop_time
		soundPlayer.volume_db = 16;
		if (!soundPlayer.playing):
			soundPlayer.play()

func _on_pause_menu_pressed() -> void:
	emit_signal("close_settings")
	visible = false

func _process(delta):
	if (timer > 0):
		timer -= delta;
	elif (soundPlayer.playing):
		if (soundPlayer.volume_db > -60):
			soundPlayer.volume_db -= delta*100;
		else:
			soundPlayer.stop()
