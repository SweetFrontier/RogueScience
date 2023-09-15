extends TextureRect


var lightIsOn : bool = true
var lightTimer := 2.0

@export
var audioPlayer : AudioStreamPlayer;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (lightTimer < 0):
		#time to change texture
		if (lightIsOn):
			#turn light off
			texture = ResourceLoader.load("res://Art/Backgrounds/title_off.png")
			audioPlayer.volume_db = -80
			lightIsOn = false
			
			lightTimer = 0.1
		else:
			#turn light on
			texture = ResourceLoader.load("res://Art/Backgrounds/title.png")
			audioPlayer.volume_db = 0
			lightIsOn = true
			
			#randomize wait between flickers between 2 and 5 seconds
			lightTimer = randf_range(1.0, 3.0)
			
			#double flicker
			if (lightTimer < 1.4):
				lightTimer = 0.1
	#timer go down
	lightTimer -= delta;
