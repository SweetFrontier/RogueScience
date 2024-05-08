extends baseTrigger

class_name bossBust

signal drop_boss_bust_signal(animationName : String)

@export var shakeStrength: float
@export var crushThreshold : int
@export var dropAnimationName : String
@export var bustSprite: AnimatedSprite2D
@export var keySound : AudioStreamPlayer2D
@export var brokeSound : AudioStreamPlayer2D

var startingPosition : Vector2
var shakeAmount : float = 0
var shakeProgress: float = 0

const buttonPressed = preload("res://Sounds/blockbreak.ogg")
const bustFall = preload("res://Sounds/firingboom.ogg")

func _ready():
	TriggerKeySprite.rotation_degrees = -rotation_degrees
	startingPosition = bustSprite.get_position()
	reset()

func react():
	bustSprite.position = startingPosition
	# Set the key to the "pressed state"
	TriggerKeySprite.frame = 1
	# Start the fade timer.
	button_fade_timer = button_fade_duration
	
	activated = false
	
	brokeSound.stream = bustFall
	brokeSound.volume_db = 10
	brokeSound.play()
	
	emit_signal("drop_boss_bust_signal", dropAnimationName)

func reset():
	super.reset()
	TriggerKeySprite.modulate.a = 0
	bustSprite.position = startingPosition
	bustSprite.frame = 0
	shakeAmount = 0
	shakeProgress = 0

func _input(event):
	# Check if the associated button is pressed and the trigger is active.
	if event is InputEventKey and event.keycode == button and event.pressed and activated and event.echo == false:
		keySound.stream = buttonPressed
		keySound.volume_db = 10
		keySound.play()
		shakeAmount += 1
		
func _process(delta):
	if activated:
		if(shakeAmount >= crushThreshold):
			react()
		shakeProgress += delta * shakeAmount * shakeStrength
		var shakePos = cos(shakeProgress)
		bustSprite.position = startingPosition + (Vector2(1,0) * shakePos) * shakeAmount * shakeStrength

func enableBossBust():
	activated = true
	TriggerKeySprite.modulate.a = 1
