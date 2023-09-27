extends baseTrigger
class_name teleporterTrigger

enum teleporterColor {
	Red,
	Blue,
	Purple,
	Yellow
}

# Exported variable for controlling the suction force.
@export var color : teleporterColor
@export var TriggerKeySprite2: AnimatedSprite2D
@export var time_to_teleport: float = 1
@export var lightningCooldown = 0.05
@export var teleporter1: Node2D
@export var teleporterArea1: Area2D
@export var teleporter2: Node2D
@export var teleporterArea2: Area2D
@export var lightning: lightning

var teleporting = false
var startingTeleporter: Node2D
var endingTeleporter: Node2D
var isDoorsClosed = false
var teleportingProgress: float = 0.0
var teleporterStartPos: Vector2
var teleporterEndPos: Vector2
var lightningProgress = 0.0
var t1Occupied = false
var t2Occupied = false
var colorString : String

func _ready():
	teleporterArea1.body_entered.connect(onT1BodyEntered)
	teleporterArea2.body_entered.connect(onT2BodyEntered)
	teleporterArea1.body_exited.connect(onT1BodyExited)
	teleporterArea2.body_exited.connect(onT2BodyExited)
	colorString = teleporterColor.keys()[color]
	match (colorString):
		"Blue":
			lightning.boltColor = Color("0FA7FF")
		"Yellow":
			lightning.boltColor = Color("DECF35")
		"Red":
			lightning.boltColor = Color("FF0712")
		"Purple":
			lightning.boltColor = Color("B95DFF")
	reset()

func react():
	if !(one_shot and activated):
		# Set the key to the "pressed state"
		TriggerKeySprite.frame = 1
		TriggerKeySprite2.frame = 1
		# Start the fade timer.
		button_fade_timer = button_fade_duration
		#change all of the animatedsprites to activated
		for child in teleporter1.get_children()+teleporter2.get_children():
			if child is AnimatedSprite2D and child.name != "TriggerKeySprite":
				child.animation = "activated" + colorString
		$Teleporter1/RodSpriteAnim.play()
		$Teleporter2/RodSpriteAnim.play()
	if !activated:
		activated = true

func reset():
	super.reset()
	# Set the key to the "unpressed state"
	TriggerKeySprite2.frame = 0
	TriggerKeySprite2.modulate.a = 1
	occupied = false
	ridingBody = null
	isDoorsClosed = false
	teleporting = false
	startingTeleporter = null
	endingTeleporter = null
	teleportingProgress = 0.0
	teleporterStartPos = Vector2(0,0)
	teleporterEndPos = Vector2(0,0)
	lightningProgress = 0.0
	lightning.hide_lightning()
	t1Occupied = false
	t2Occupied = false	
	
	#make sure everything is deactivated
	for child in teleporter1.get_children()+teleporter2.get_children():
		if child is AnimatedSprite2D and child.name != "TriggerKeySprite":
			child.animation = "deactivated" + colorString
	
	if startActivated:
		react()
		button_fade_timer = 0
		TriggerKeySprite.modulate.a = 0
		TriggerKeySprite2.modulate.a = 0

func set_button(_button):
	super.set_button(_button)
	if activated:
		return
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
	if !body is Player and !body is movingObject and !body is rigidPlayer:
		return
	if t1Occupied or t2Occupied:
		return
	if activated and body != self and !occupied and body != ridingBody:
		startingTeleporter = teleporter
		if startingTeleporter == teleporter1:
			t1Occupied = true
			endingTeleporter = teleporter2
		else:
			t2Occupied = true
			endingTeleporter = teleporter1
		if body is movingObject or body is rigidPlayer:
			if body.movement_overrider != null:
				body.movement_overrider.free_movement()
			override_movement(body)
			body.set_freed_vel(body.angular_velocity, body.linear_velocity)

func _on_body_exited(body, teleporter):
	if !body is Player and !body is movingObject and !body is rigidPlayer:
		return
	if teleporting:
		return
	if (t1Occupied and teleporter == teleporter1) or (t2Occupied and teleporter == teleporter2):
		return
	# Check if the exited body was inside the elevator.
	occupied = false
	t1Occupied = false
	t2Occupied = false

func setupMoveToStart():
	super.setupMoveToStart()
	#endRiderPos = position + startingTeleporter.position
	endRiderPos = startingTeleporter.global_position

func riderReady():
	super.riderReady()
	closeDoors()

func closeDoors():
	isDoorsClosed = true
	$Teleporter1/FrontingSpriteAnim.play()
	$Teleporter2/FrontingSpriteAnim.play()

func doorsAnimFinished():
	if isDoorsClosed:
		isDoorsClosed = false
		teleportingProgress = 0.0
		#teleporterEndPos = endingTeleporter.position + position
		teleporterEndPos = endingTeleporter.global_position
		teleporting = true
		ridingBody.visible = false
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
		ridingBody.set_body_pos(teleporterEndPos)
		ridingBody.visible = true
		$Teleporter1/FrontingSpriteAnim.play_backwards()
		$Teleporter2/FrontingSpriteAnim.play_backwards()
		teleporting = false
		free_movement()
		ridingBody = null
