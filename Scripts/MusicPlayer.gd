extends AudioStreamPlayer

@export var animationPlayer : AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func changeMusic(musicName : String):
	animationPlayer.play('fadeOut')
	await animationPlayer.animation_finished
	volume_db = 0;
	set_stream(load("res://Sounds/Music/puzzle("+musicName+").ogg"))
	play()

func fadeOut():
	animationPlayer.play('fastFade')
	await animationPlayer.animation_finished
	stop()

func fadeBackIn():
	volume_db = -80
	play()
	animationPlayer.play('fadeBackIn')
