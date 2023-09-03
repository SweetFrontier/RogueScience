extends baseTrigger
class_name invisibleBlock

# Exported variable for controlling the opacity when the block is invisible.
@export var translucent_opacity = 0.3
@export var body : StaticBody2D
@export var implodeable_polygon: explodeablePolygon

func _ready():
	super._ready()
	if(activated):
		activated = false;
		react()
	else:
		reset()

# Override the baseTrigger's react method to toggle visibility and collision.
func react():
	super.react()
	if !activated:
		activated = true
		# Explode the Block
		implodeable_polygon.implode()
		# Enable collision.
		body.collision_layer = 1

func reset():
	super.reset()
	implodeable_polygon.reset()
	# Make the block translucent
	implodeable_polygon.color.a = translucent_opacity
	# Make sure there will be no collisions
	body.collision_layer = 0
