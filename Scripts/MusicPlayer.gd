extends AudioStreamPlayer

@export var animationPlayer : AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func changeMusic(musicName : String):
	if (playing):
		animationPlayer.play('fadeOut')
		await animationPlayer.animation_finished
	elif ($bossyfloppo.playing):
		animationPlayer.play('fastFadeFlopBoss')
		await animationPlayer.animation_finished
	volume_db = 0;
	if (musicName.substr(0,3) == 'bos'):
		set_stream(load("res://Sounds/Music/"+musicName+".ogg"))
		if musicName == "boss4":
			animationPlayer.play("flop")
	else:
		set_stream(load("res://Sounds/Music/puzzle("+musicName+").ogg"))
	play()

func fadeOut():
	if (playing):
		animationPlayer.play('fastFade')
		await animationPlayer.animation_finished
	else:
		#if im not playing then floppo is. get that one to stop
		animationPlayer.play('fastFadeFlopBoss')
		await animationPlayer.animation_finished
	stop()

func fadeBackIn():
	volume_db = -80
	play()
	animationPlayer.play('fadeBackIn')
