extends ColorRect

@export var animationPlayer : AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	show()
	await(animationPlayer.animation_finished)
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _hide():
	hide()

func cover_screen():
	show()
	animationPlayer.play("FadeToBlack")
