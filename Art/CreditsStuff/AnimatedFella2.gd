extends Sprite2D

var moving : bool = false
var horizspd : float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (moving):
		#move a bit, then decrease horizspd, then move a bit more
		position.x += horizspd*delta;
		horizspd -= delta*100
		if (horizspd < 0): horizspd = 0
		position.x += horizspd*delta;

func pull():
	if (moving):
		horizspd = 100;


func _on_area_2d_area_entered(area):
	#if already moving then DELETE
	if (moving):
		for n in get_children():
			n.queue_free()
		queue_free()
	
	#if not then MOVE
	moving = true
