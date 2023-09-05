extends AnimatedSprite2D

var moving : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (moving):
		position.x += delta*70

func _on_area_2d_area_entered(area):
	#if already moving then DELETE
	if (moving):
		for n in get_children():
			n.queue_free()
		queue_free()
	
	#if not then MOVE
	moving = true
