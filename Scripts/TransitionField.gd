extends Area2D

@onready var camera : Camera2D = get_tree().root.get_node("Main/Camera2D")
@onready var main : Main = get_tree().root.get_node("Main")

@export_category("Camera Controls")
@export var x_move : float = 1280
@export var y_move : float = 0
@onready var final_x : float = camera.position.x + x_move
@onready var final_y : float = camera.position.y + y_move

# 1 is the default size >1 is smaller viewport
@export var x_size : int = 1
@export var y_size : int = 1

var moving : bool = false
var zooming : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(true)

func _process(delta):
	if (moving):
		var smooth_move_x = lerp(camera.position.x, final_x, 1 * delta)
		var smooth_move_y = lerp(camera.position.y, final_y, 1 * delta)
		if (smooth_move_x != final_x or smooth_move_y != final_y):
			camera.position = Vector2(smooth_move_x, smooth_move_y)
		else:
			moving = false
		
	if (zooming):
		var smooth_zoom_x = lerp(camera.zoom.x, x_size as float, 1 * delta)
		var smooth_zoom_y = lerp(camera.zoom.y, y_size as float, 1 * delta)
		if smooth_zoom_x != x_size or smooth_zoom_y != y_size:
			camera.set_zoom(Vector2(smooth_zoom_x, smooth_zoom_y))
		else:
			zooming = false

func _on_body_entered(body: Node2D) -> void:
	if (body.name == "Player"):
		set_deferred("monitoring", false)
		main.current_level += 1
		moving = true
		zooming = true

func move_camera() -> void:
	camera.limit_left += x_move
	camera.limit_right += x_move
	camera.limit_bottom += y_move
	camera.limit_top += y_move
