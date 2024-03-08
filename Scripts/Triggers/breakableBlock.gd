extends baseTrigger
class_name breakableBlocks

# Exported variable for controlling the opacity when the block is invisible.
@export var invisible_opacity: float = 0.0
@export var explodeable_polygon: explodeablePolygon
@export var animSprite: AnimatedSprite2D
@export var body: StaticBody2D
@export var sound_child : AudioStreamPlayer2D

func _ready():
	super._ready()
	explodeable_polygon.connect("finished_imploding_signal", finished_imploding)
	reset()

# Override the baseTrigger's react method to toggle visibility, collision, and emit particles.
func react():
	super.react()
	destroy(true)

func reset():
	super.reset()
	# unexplode the Block
	explodeable_polygon.reset()
	# Enable collision.
	body.collision_layer = 1
	#If has an Animated Sprite, make that visible
	if animSprite:
		animSprite.visible = false
	explodeable_polygon.visible = true
	if startActivated:
		explodeable_polygon.color.a = 1
		react()
		button_fade_timer = 0
		TriggerKeySprite.modulate.a = 0
	else:
		explodeable_polygon.color.a = 0
		explodeable_polygon.implode()

func destroy(fadeKey: bool = true):
	if !activated:
		if !fadeKey:
			button_fade_timer = 0
			TriggerKeySprite.modulate.a = 0
		activated = true
		if animSprite:
			explodeable_polygon.visible = true
			animSprite.visible = false
		# Explode the Block
		explodeable_polygon.explode()
		# Disable collision.
		body.collision_layer = 0
		#play the boom sound
		sound_child.play()

func finished_imploding():
	#Once finished imploding, make the animatedSprite2D visible if it exists
	if animSprite:
		animSprite.visible = true
		explodeable_polygon.visible = false
