extends baseTrigger
class_name teleporterTrigger

# Exported variable for controlling the suction force.
@export var TriggerKeySprite2: AnimatedSprite2D
@export var time_to_teleport: float = 1
@export var lightningCooldown = 0.05
@export var teleporter1: AnimatedSprite2D
@export var teleporterArea1: Area2D
@export var teleporter2: AnimatedSprite2D
@export var teleporterArea2: Area2D
@export var lightning: lightning

var teleporting = false
var reached_stop = false
var startingTeleporter: AnimatedSprite2D
var endingTeleporter: AnimatedSprite2D
var teleportingProgress: float = 0.0
var teleporterStartPos: Vector2
var teleporterEndPos: Vector2
var lightningProgress = 0.0

func _ready():
	super._ready()
	if activated:
		activated = false
		react()
	else:
		reset()
	teleporterArea1.body_entered.connect(onT1BodyEntered)
	teleporterArea2.body_entered.connect(onT2BodyEntered)
	teleporterArea1.body_exited.connect(onT1BodyExited)
	teleporterArea2.body_exited.connect(onT2BodyExited)

func react():
	if !(one_shot and activated):
		# Set the key to the "pressed state"
		TriggerKeySprite.frame = 1
		TriggerKeySprite2.frame = 1
		# Start the fade timer.
		button_fade_timer = button_fade_duration
	if !activated:
		activated = true

func reset():
	super.reset()
	# Set the key to the "unpressed state"
	TriggerKeySprite2.frame = 0
	TriggerKeySprite2.modulate.a = 1
	occupied = false
	ridingBody = null

func set_button(_button):
	super.set_button(_button)
	if _button in buttonToAnimation:
		button = _button
		TriggerKeySprite2.animation = buttonToAnimation[button]
	else:
		TriggerKeySprite2.animation = "default"

func _physics_process(delta):
	if button_fade_timer > 0.0:
		# Calculate the new opacity based on the elapsed time and fade duration.
		var new_opacity = lerp(1, 0, 1.0 - (button_fade_timer / button_fade_duration))
		TriggerKeySprite.modulate.a = new_opacity
		TriggerKeySprite2.modulate.a = new_opacity
		# Decrease the fade timer.
		button_fade_timer -= delta
	if !occupied:
		return
	if !riderInPosition:
		if ridingBody is Player:
			ridingBody.rotate_player_on_arc(delta)
		moveRiderToStarting(delta)
	if teleporting:
		teleport(delta)

func onT1BodyEntered(body):
	_on_body_entered(body, teleporter1)
func onT1BodyExited(body):
	_on_body_exited(body, teleporter1)
func onT2BodyEntered(body):
	_on_body_entered(body, teleporter2)
func onT2BodyExited(body):
	_on_body_exited(body, teleporter2)

func _on_body_entered(body, teleporter):
	if activated and body != self and !occupied and body != ridingBody:
		startingTeleporter = teleporter
		endingTeleporter = teleporter2 if(startingTeleporter == teleporter1) else teleporter1
		override_movement(body)

func _on_body_exited(body, teleporter):
	# Check if the exited body was inside the elevator.
	if occupied and body == ridingBody:
		occupied = false
		ridingBody = null

func setupMoveToStart():
	super.setupMoveToStart()
	endRiderPos = position + startingTeleporter.position
	reached_stop = false

func riderReady():
	super.riderReady()
	setupTeleporterStarting()

func setupTeleporterStarting():
	teleportingProgress = 0.0
	teleporterEndPos = endingTeleporter.position + position
	teleporting = true
	lightning.show_lightning()

func teleport(delta):
	teleportingProgress += delta
	lightningProgress += delta
	if lightningProgress >= lightningCooldown:
		lightningProgress = 0.0
		lightning.lightning_strike()
	# Check if the time to teleport is complete, then instantly teleport
	if teleportingProgress >= time_to_teleport:
		lightning.hide_lightning()
		ridingBody.position = teleporterEndPos
		teleporting = false
		reached_stop = true
		free_movement()
