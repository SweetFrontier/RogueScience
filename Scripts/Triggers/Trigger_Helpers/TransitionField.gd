extends Area2D

class_name TransitionField

signal increase_level_signal

func _on_body_entered(body: Node2D) -> void:
	if (body is Player):
		set_deferred("monitoring", false)
		emit_signal("increase_level_signal")
