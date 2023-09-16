extends baseTrigger
class_name invisibleBlock

# Exported variable for controlling the opacity when the block is invisible.
@export var translucent_opacity = 0.3
@export var body : StaticBody2D
@export var implodeable_polygon: explodeablePolygon
@export var sound_child : AudioStreamPlayer2D

func _ready():
	super._ready()
	reset()

# Override the baseTrigger's react method to toggle visibility and collision.
func react():
	super.react()
	if !activated:
		activated = true
		# Explode the Block
		implodeable_polygon.implode()
		# Enable collision.
		body.enable()
		#play the boom sound
		sound_child.play()

func reset():
	super.reset()
	implodeable_polygon.reset()
	# Make the block translucent
	implodeable_polygon.color.a = translucent_opacity
	# Make sure there will be no collisions
	body.disable()
	if startActivated:
		react()
		button_fade_timer = 0
		TriggerKeySprite.modulate.a = 0
