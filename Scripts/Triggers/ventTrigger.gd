extends baseTrigger

class_name ventTrigger

@export var ventExtranceDirection: Direction
@export var ventExitDirection: Direction
@export var entrance: Node2D
@export var entranceSprite: AnimatedSprite2D
@export var doorStop: explodeablePolygon
@export var exit: Node2D
@export var exitSprite: AnimatedSprite2D

var rider_freeable = false
var currState: VentState = VentState.CLOSED

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
	reset()

func react():
	super.react()
	if !activated:
		activated = true
		currState = VentState.OPENING
		entranceSprite.animation = stateToAnimString[currState]
		entranceSprite.play()

func reset():
	super.reset()
	currState = VentState.CLOSED
	entranceSprite.animation = stateToAnimString[currState]
	doorStop.visible = false

func _physics_process(delta):
	super._physics_process(delta)
	if !occupied:
		return
	if !riderInPosition:
		moveRiderToStarting(delta)

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

func onShutVentAreaEntered(body):
	if !body is rigidPlayer and !body is movingObject:
		return
	if currState == VentState.OPEN and !occupied and body != self and entrance.scale.x * (body.global_position.x-$VentEntrance/ShutVentArea.global_position.x) < 0:
		doorStop.visible = true
		doorStop.explode()
		currState = VentState.READYTOVENT
		entranceSprite.animation = stateToAnimString[currState]
		entranceSprite.play()

func onInsideCheckVentAreaEntered(body):
	if !body is rigidPlayer and !body is movingObject:
		return
	if currState == VentState.READYTOVENT and !occupied and body != self:
		override_movement(body)
		#Uncomment to keep momentum lol
		#body.set_freed_vel(body.angular_velocity, body.linear_velocity)
		rider_freeable = false
		ridingBody.hide()
		riderReady()
		teleportRider()
		resetVenting()

func onEntranceAnimationFinished():
	if entranceSprite.animation == stateToAnimString[VentState.OPENING]:
		currState = VentState.OPEN
		entranceSprite.animation = stateToAnimString[currState]
