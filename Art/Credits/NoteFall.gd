extends RigidBody2D

var active : bool = false
var falling : bool = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Called when the node enters the scene tree for the first time.
func _ready():
	linear_damp = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (falling):
		get_child(0).rotation_degrees += delta*10
		if (linear_velocity.y > 10):
			pass



func _on_area_2d_area_entered(area):
	if (!active):
		#if not activated to fall then set that
		active = true
	elif (!falling):
		#if already activated to fall then start falling
		falling = true
		apply_impulse(Vector2(400, 0))
		gravity_scale = 1
		linear_damp = 1
	else:
		#third time means delete self now
		for n in get_children():
			n.queue_free()
		queue_free()
