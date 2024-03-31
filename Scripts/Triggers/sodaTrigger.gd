extends baseTrigger

class_name sodaTrigger

@export var explosionThreshold: float = 5
@export var shakeStrength: float = 1
@export var shakeDecay: float = 0.0167
@export var launch_speed: float
@export var splat : bool = true
@export var bottleSprite: AnimatedSprite2D
@export var spewSprite: AnimatedSprite2D
@export var sodaBall: SodaBall
@export var SPLAT_PACKEDSCENE: PackedScene

var currState: SodaState = SodaState.FULL
var startingPosition : Vector2
var shakeAmount: float = 0
var shakeProgress: float = 0
var splatList : Array = []
var timeSinceReset : float = 0

enum SodaState
{
	FULL,
	SHAKING,
	SPEWING,
	EMPTY
}

# Called when the node enters the scene tree for the first time.
func _ready():
	TriggerKeySprite.rotation_degrees = -rotation_degrees
	if !show_button:
		TriggerKeySprite.modulate.a = 0
	currState = SodaState.FULL
	startingPosition = bottleSprite.get_position()
	$SodaBall.rotation = rotation
	$SodaBall.LAUNCH_SPEED = launch_speed
	$SodaBall.splat = splat
	reset()

func _input(event):
	# Check if the associated button is pressed and the trigger is active.
	if event is InputEventKey and event.keycode == button and event.pressed and !activated and event.echo == false:
		if(shakeAmount <= shakeStrength*2):
			shakeAmount = shakeStrength*2
		shakeAmount += shakeStrength
		currState = SodaState.SHAKING


func react():
	if !startActivated:
		emit_signal("remove_key_signal",self,button)
		emit_signal("randomize_block_keys_signal")
	if !(one_shot and activated):
		# Set the key to the "pressed state"
		TriggerKeySprite.frame = 1
		# Start the fade timer.
		button_fade_timer = button_fade_duration
	
	if !activated:
		activated = true
		currState = SodaState.SPEWING
		bottleSprite.animation = "spewing"
		bottleSprite.play()
		spewSprite.visible = true
		sodaBall.launch()

func reset():
	super.reset()
	currState = SodaState.FULL
	sodaBall.reset()
	bottleSprite.position = startingPosition
	bottleSprite.animation = "full"
	bottleSprite.frame = 0
	spewSprite.visible = false
	shakeAmount = 0
	shakeProgress = 0
	timeSinceReset = 0
	
	var nextSplat = splatList.pop_back()
	while (nextSplat != null):
		nextSplat.queue_free()
		nextSplat = splatList.pop_back()
	
	if startActivated:
		react()
		if show_button:
			button_fade_timer = 0
			TriggerKeySprite.modulate.a = 0
		shakeAmount = explosionThreshold

func recieve_splat(gPosition : Vector2):
	#Don't splat if the room just reset
	#This check is due to delay in recieving splat signal
	if(timeSinceReset < 0.0167):
		return
	var newSplat = SPLAT_PACKEDSCENE.instantiate()
	add_child(newSplat)
	newSplat.global_position = gPosition
	newSplat.global_position.x = roundf(newSplat.global_position.x/32.0)*32
	newSplat.global_position.y = roundf(newSplat.global_position.y/32.0)*32
	splatList.append(newSplat)

func _process(delta):
	timeSinceReset += delta
	match(currState):
		SodaState.SHAKING:
			shakeAmount = max(shakeAmount - shakeDecay, 0)
			if(shakeAmount >= explosionThreshold):
				react()
			shakeProgress += delta * shakeAmount
			bottleSprite.position = startingPosition + (Vector2(0,1) * sin(shakeProgress)).rotated(bottleSprite.rotation) * shakeAmount
		SodaState.SPEWING:
			shakeAmount = max(shakeAmount - shakeDecay*5, 0)
			if(shakeAmount <= 0):
				currState = SodaState.EMPTY
				spewSprite.visible = false
				bottleSprite.animation = "empty"
			shakeProgress += delta * shakeAmount
			bottleSprite.position = startingPosition + (Vector2(0,1) * sin(shakeProgress)).rotated(bottleSprite.rotation) * shakeAmount
