extends Area2D

class_name TransitionField

signal increase_level_signal
signal start_end_sequence

@export var bossLevel : bool = false

func _on_body_entered(body: Node2D) -> void:
	if (body is rigidPlayer):
		if body.dead:
			return
		set_deferred("monitoring", false)
		if !bossLevel:
			changeLevel()
		else:
			emit_signal("start_end_sequence")

func changeLevel():
	emit_signal("increase_level_signal")
