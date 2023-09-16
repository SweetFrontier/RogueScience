extends StaticBody2D

var expand : bool = true
var timer : float = 0

#collision shape
@export var collisionShape : Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#expansion
	if (expand):
		collisionShape.scale += Vector2(delta*10, delta*10)
		#if expanded too far then set back to full size and stop expanding
		if (collisionShape.scale >= Vector2(1, 1)):
			collisionShape.scale = Vector2(1, 1)
			expand = false
	
	#timer for (forgiving) one way collisions
	if (timer > 0):
		timer -= delta
		if (timer <= 0):
			collisionShape.one_way_collision = false
			collisionShape.hide()

func enable():
	#expand
	expand = true
	#enable collision
	collision_layer = 1
	#start timer for one way collisions
	timer = 0.6
	collisionShape.one_way_collision = true
	collisionShape.one_way_collision_margin = 10
	#make expand texture visible
	collisionShape.show()

func disable():
	#disable expansion
	expand = false
	#shrink collision shape
	collisionShape.scale = Vector2(0, 0)
	#disable collision
	collision_layer = 0
	#reset timer for one way collisions upon activation
	timer = 0
