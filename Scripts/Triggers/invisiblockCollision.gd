extends StaticBody2D

var expand : bool = true
var timer : float = 0

#collision shape
@export var collisionShape : Node2D
#number in seconds in which one way collision is deactivated
@export var oneWayTimer : float = 0.6
#collisionshapes to the left and right of the invisible block
@export var tempOneWayShapes : Array[Node2D] #0 MUST BE L, 1 MUST BE R

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
			set_collision_layer_value(1, true) #1 is for normal collisions
			collisionShape.one_way_collision = false
			collisionShape.hide()
			#kill the oneway colliders for the left and right sides
			for i in tempOneWayShapes.size():
				tempOneWayShapes[i].collision_layer = 0

func enable():
	#expand
	expand = true
	#enable collision
	set_collision_layer_value(2, true) #2 is for one way collisions
	#start timer for one way collisions
	timer = oneWayTimer
	collisionShape.one_way_collision = true
	collisionShape.one_way_collision_margin = 128
	#make expand texture visible
	collisionShape.show()
	#enable the side collision shapes
	if (tempOneWayShapes.size() > 1):
		tempOneWayShapes[0].set_collision_layer_value(4, true) #4 is oneWayLHS
		tempOneWayShapes[1].set_collision_layer_value(3, true) #3 is oneWayRHS

func disable():
	#disable expansion
	expand = false
	#shrink collision shape
	collisionShape.scale = Vector2(0, 0)
	collisionShape.hide()
	#disable collision
	collision_layer = 0
	#disable child collision
	for i in tempOneWayShapes.size():
		tempOneWayShapes[i].collision_layer = 0
	#reset timer for one way collisions upon activation
	timer = 0
