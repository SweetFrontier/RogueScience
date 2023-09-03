extends Area2D

@onready var camera : Camera2D = get_tree().root.get_node("Main/Camera2D")
@onready var main : Main = get_tree().root.get_node("Main")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if (body.name == "Player"):
		set_deferred("monitoring", false)
		main.current_level += 1
		camera.limit_left += 1280
		camera.limit_right += 1280
