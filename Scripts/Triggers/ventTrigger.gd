extends baseTrigger

class_name ventTrigger

@export var ventPathHolder: Node2D
@export var ventExtranceDirection: Direction
@export var ventExitDirection: Direction
@export var entrance: Node2D
@export var entranceSprite: AnimatedSprite2D
@export var doorStop: explodeablePolygon
@export var exit: Node2D
@export var exitSprite: AnimatedSprite2D
@export var audio: AudioStreamPlayer2D

var ventAnimSprites: Array[AnimatedSprite2D]
var rider_freeable = false
var currState: VentState = VentState.CLOSED
var currVentIndex = 0
var soundTimer = 0.08;

enum VentState
{
	CLOSED,
	OPENING,
	OPEN,
	READYTOVENT,
	VENTING
}

enum Direction
{
	LEFT,
	RIGHT
}

var stateToAnimString = {
	VentState.CLOSED: "closed",
	VentState.OPENING: "opening",
	VentState.OPEN: "open",
	VentState.READYTOVENT: "closing",
	VentState.VENTING: "closed"
}

func _ready():
	super._ready()
	TriggerKeySprite.rotation_degrees = -rotation_degrees
	if ventExtranceDirection == Direction.LEFT:
		entrance.scale.x = 1
	else:
		entrance.scale.x = -1
	if ventExitDirection == Direction.LEFT:
		exit.scale.x = 1
	else:
		exit.scale.x = -1
	var newSphere = CircleShape2D.new()
	newSphere.radius = 0
	$VentEntrance/BallCollision/CollisionShape2D.shape = newSphere
	for child in ventPathHolder.get_children():
		ventAnimSprites.append(child as AnimatedSprite2D)
		child.frame_changed.connect(onVentFrameChanged)
	determineVentOrientations()
	reset()

func react():
	super.react()
	if !activated:
		activated = true
		currState = VentState.OPENING
		entranceSprite.animation = stateToAnimString[currState]
		entranceSprite.play()
		$VentEntrance/BallCollision/CollisionShape2D.shape.radius = 1+entranceSprite.frame*3
		$VentEntrance/BallCollision/CollisionShape2D.position.y = 15-entranceSprite.frame*3

func reset():
	super.reset()
	currState = VentState.CLOSED
	entranceSprite.animation = stateToAnimString[currState]
	doorStop.visible = false
	currVentIndex = 0
	$VentEntrance/BallCollision/CollisionShape2D.position.y = -10000
	for vent in ventAnimSprites:
		vent.frame = 0
		vent.stop()
	if startActivated:
		react()
		if show_button:
			button_fade_timer = 0
			TriggerKeySprite.modulate.a = 0


func _physics_process(delta):
	super._physics_process(delta)
	if !occupied:
		return
	if !riderInPosition:
		moveRiderToStarting(delta)
	soundTimer -= delta
	if (soundTimer < 0):
		soundTimer += 0.08
		audio.pitch_scale -= 0.025
		audio.play()

func teleportRider():
	ridingBody.set_body_pos(exit.global_position)
	if ridingBody is rigidPlayer:
		ridingBody.changeDirection(Vector2.LEFT if ventExitDirection == Direction.LEFT else Vector2.RIGHT)
	ridingBody.show()
	free_movement()

func resetVenting():
	currState = VentState.OPENING
	entranceSprite.animation = stateToAnimString[currState]
	entranceSprite.play()
	currVentIndex = 0

func onShutVentAreaEntered(body):
	if !body is rigidPlayer and !body is movingObject:
		return
	if currState == VentState.OPEN and !occupied and body != self and entrance.scale.x * (body.global_position.x-$VentEntrance/ShutVentArea.global_position.x) < 0:
		doorStop.visible = true
		doorStop.explode()
		currState = VentState.READYTOVENT
		entranceSprite.animation = stateToAnimString[currState]
		entranceSprite.play()
		#disabling the collision shape would have to be deferred, instead we just move the position away
		$VentEntrance/BallCollision/CollisionShape2D.position.y = -10000

func onInsideCheckVentAreaEntered(body):
	if !body is rigidPlayer and !body is movingObject:
		return
	if currState == VentState.READYTOVENT and !occupied and body != self:
		if body.movement_overrider != null:
			body.movement_overrider.free_movement()
		override_movement(body)
		#Uncomment to keep momentum lol
		#if body is movingObject:
			#body.set_freed_vel(body.angular_velocity, body.linear_velocity)
		rider_freeable = false
		ridingBody.hide()
		riderReady()
		ventAnimSprites[0].play()
		audio.position = position
		audio.pitch_scale = 0.7+ventAnimSprites.size()*0.05
		audio.play()

func onEntranceAnimationFinished():
	if entranceSprite.animation == stateToAnimString[VentState.OPENING]:
		currState = VentState.OPEN
		entranceSprite.animation = stateToAnimString[currState]

func onEntranceSpriteFrameChanged():
	if entranceSprite.animation == stateToAnimString[VentState.OPENING] && entranceSprite.frame > 0:
		$VentEntrance/BallCollision/CollisionShape2D.shape.radius = 1+entranceSprite.frame*3
		$VentEntrance/BallCollision/CollisionShape2D.position.y = 15-entranceSprite.frame*3

func onVentFrameChanged():
	if currVentIndex >= ventAnimSprites.size():
		return
	var currVent = ventAnimSprites[currVentIndex]
	if currVent.frame == 8:
		currVentIndex += 1
		if currVentIndex >= ventAnimSprites.size():
			teleportRider()
			resetVenting()
			return
		currVent = ventAnimSprites[currVentIndex]
		currVent.play()
		audio.position = currVent.position
		#audio.pitch_scale -= 0.025
		#audio.play()

func determineVentOrientations():
	var orientations = []
	for i in range(ventAnimSprites.size()):
		var current = ventAnimSprites[i]
		var prev = ventAnimSprites[i - 1] if i > 0 else entrance
		
		var x_diff = current.global_position.x - prev.global_position.x
		var y_diff = current.global_position.y - prev.global_position.y
		
		if x_diff == 0:
			if y_diff == 0:
				#Don't do anything, 'cause broke
				print_debug("Vent on top of adjacent vent")
			elif y_diff > 0:
				if i > 0:
					orientations[i-1] += 1 << 6
				orientations.append(1 << 3)
			else:
				if i > 0:
					orientations[i-1] += 1 << 7
				orientations.append(1 << 2)
		elif x_diff > 0:
			if i > 0:
				orientations[i-1] += 1 << 4
			orientations.append(1 << 1)
		else:
			if i > 0:
				orientations[i-1] += 1 << 5
			orientations.append(1 << 0)
	orientations[orientations.size()-1] += 1<<5 if ventExitDirection == Direction.LEFT else 1<<4
	
	for i in range(orientations.size()):
		match orientations[i]:
			132:
				#"Down - Up"
				ventAnimSprites[i].animation = "straight"
			130:
				#"Left - Up"
				ventAnimSprites[i].animation = "curved"
				ventAnimSprites[i].rotate(deg_to_rad(90))
			129:
				#"Right - Up"
				ventAnimSprites[i].animation = "curved"
				ventAnimSprites[i].rotate(deg_to_rad(-90))
				ventAnimSprites[i].flip_h = true
			72:
				#"Up - Down"
				ventAnimSprites[i].animation = "straight"
				ventAnimSprites[i].flip_v = true
			66:
				#"Left - Down"
				ventAnimSprites[i].animation = "curved"
				ventAnimSprites[i].rotate(deg_to_rad(90))
				ventAnimSprites[i].flip_h = true
			65:
				#"Right - Down"
				ventAnimSprites[i].animation = "curved"
				ventAnimSprites[i].rotate(deg_to_rad(-90))
			40:
				#"Up - Left"
				ventAnimSprites[i].animation = "curved"
				ventAnimSprites[i].flip_v = true
			36:
				#"Down - Left"
				ventAnimSprites[i].animation = "curved"
			33:
				#"Right - Left"
				ventAnimSprites[i].animation = "straight"
				ventAnimSprites[i].rotate(deg_to_rad(-90))
			24:
				#"Up - Right"
				ventAnimSprites[i].animation = "curved"
				ventAnimSprites[i].flip_v = true
				ventAnimSprites[i].flip_h = true
			20:
				#"Down - Right"
				ventAnimSprites[i].animation = "curved"
				ventAnimSprites[i].flip_h = true
			18:
				#"Left - Right"
				ventAnimSprites[i].animation = "straight"
				ventAnimSprites[i].rotate(deg_to_rad(90))
	
