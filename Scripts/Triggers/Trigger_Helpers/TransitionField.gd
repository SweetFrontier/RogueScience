extends Area2D

@onready var main : Main = get_tree().root.get_node("Main")

func _on_body_entered(body: Node2D) -> void:
	if (body is Player):
		set_deferred("monitoring", false)
		main.increase_level()
