extends RigidBody2D

var active : bool = false
var falling : bool = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export
var my_texture : TextureRect

# Called when the node enters the scene tree for the first time.
func _ready():
	linear_damp = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (falling):
		# vertical velocity over 1000 means delete
		if (linear_velocity.y > 1500):
			for n in get_children():
				n.queue_free()
				queue_free()
		else:
			# otherwise do a fancy texture rotation
			my_texture.rotation_degrees += delta*15



func _on_area_2d_area_entered(_area):
	if (!active):
		#if not activated to fall then set that
		active = true
	elif (!falling):
		#if already activated to fall then start falling
		falling = true
		apply_impulse(Vector2(200, 0))
		gravity_scale = 1.8
		linear_damp = 1
