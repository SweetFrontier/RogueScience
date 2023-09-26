extends ColorRect

@export var animationPlayer : AnimationPlayer

signal screenCovered

# Called when the node enters the scene tree for the first time.
func _ready():
	show()
	await(animationPlayer.animation_finished)
	hide()

func _hide():
	hide()

func cover_screen():
	show()
	animationPlayer.play("FadeToBlack")
	await animationPlayer.animation_finished
	emit_signal("screenCovered")

func uncover_screen():
	show()
	animationPlayer.play("FadeFastFromBlack")
	await(animationPlayer.animation_finished)
	hide()
