extends baseTrigger
class_name trampolineTrigger

# Exported variable for controlling the jump force.
@export var jump_force: float = 500.0
@export var area2D: Area2D
@export var BlockSprite: AnimatedSprite2D
@export var MoveToPosition: Node2D

func _ready():
	super._ready()
	area2D.body_entered.connect(_on_body_entered)
	area2D.body_exited.connect(_on_body_exited)

func _input(event):
	if event is InputEventKey and event.keycode == button and event.pressed:
		react()  # Call the react method when the button is pressed.

func react():
	super.react()
	if(!activated):
		activated = true

func reset():
	super.reset()

func _on_body_entered(body):
	if activated and body != self:
		if body.has_method("apply_impulse"):
			body.apply_impulse(Vector2(0, -jump_force*3))
		elif body.has_method("touched_trampoline"):
			body.touched_trampoline(-jump_force, position+MoveToPosition.position)
		BlockSprite.frame = 1

func _on_body_exited(_body):
	BlockSprite.frame = 0
