extends baseTrigger
class_name breakableBlocks

# Exported variable for controlling the opacity when the block is invisible.
@export var invisible_opacity: float = 0.0
@export var explodeable_polygon: explodeablePolygon
@export var body: StaticBody2D
@export var sound_child : AudioStreamPlayer2D

func _ready():
	super._ready()
	reset()

# Override the baseTrigger's react method to toggle visibility, collision, and emit particles.
func react():
	super.react()
	if !activated:
		activated = true
		# Explode the Block
		explodeable_polygon.explode()
		# Disable collision.
		body.collision_layer = 0
		#play the boom sound
		sound_child.play()

func reset():
	super.reset()
	# unexplode the Block
	explodeable_polygon.reset()
	# Enable collision.
	body.collision_layer = 1
	if startActivated:
		explodeable_polygon.color.a = 1
		react()
		button_fade_timer = 0
		TriggerKeySprite.modulate.a = 0
	else:
		explodeable_polygon.color.a = 0
		explodeable_polygon.implode()
