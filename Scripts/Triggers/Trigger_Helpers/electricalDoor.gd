extends baseTrigger
class_name electricalDoor

@export var doorSprite : AnimatedSprite2D
@export var staticBody : StaticBody2D
@export var collisionShape : CollisionShape2D
@export var soundChild : AudioStreamPlayer2D
@export var startState : DoorState

var currState : DoorState = DoorState.OPEN
const closedDoorHeight = 4
var doorHeight : float
var doorFrameCount : int
var scaleChange : Vector2
var positionChange : Vector2

enum DoorState
{
	OPEN,
	CLOSING,
	CLOSED,
	OPENING
}

var stateToAnimString = {
	DoorState.OPEN: "open",
	DoorState.CLOSING: "closing",
	DoorState.CLOSED: "closed",
	DoorState.OPENING: "opening"
}

func _ready():
	show_button = false
	super._ready()
	doorHeight = doorSprite.sprite_frames.get_frame_texture("opening",0).get_height()
	doorFrameCount = doorSprite.sprite_frames.get_frame_count("closing")
	scaleChange = Vector2(0, ((doorHeight-closedDoorHeight)/(doorFrameCount-1))/doorHeight)
	positionChange = Vector2(0, ((doorHeight-closedDoorHeight)/(doorFrameCount-1))/2)
	reset()

# Override the baseTrigger's react method to toggle visibility and collision.
func react():
	super.react()
	if (activated and !one_shot) or !activated:
		activated = true
		match(currState):
			DoorState.OPEN:
				changeState(DoorState.CLOSING)
			DoorState.CLOSING:
				changeState(DoorState.OPENING)
			DoorState.CLOSED:
				changeState(DoorState.OPENING)
			DoorState.OPENING:
				changeState(DoorState.CLOSING)
		#play the boom sound
		soundChild.play()

func reset():
	super.reset()
	changeState(startState)
	if startActivated:
		react()
		if show_button:
			button_fade_timer = 0
			TriggerKeySprite.modulate.a = 0

func destroy():
	#can't destroy this, these are security doors
	pass

func changeState(newState : DoorState):
	var startingFrame = 0
	if (currState == DoorState.CLOSING or currState == DoorState.OPENING) and (newState == DoorState.CLOSING or newState == DoorState.OPENING):
		startingFrame = doorFrameCount-(doorSprite.frame+1)
	currState = newState
	doorSprite.animation = stateToAnimString[currState]
	doorSprite.frame = startingFrame
	doorSprite.play()
	match currState:
		DoorState.OPEN, DoorState.CLOSING:
			collisionShape.scale = Vector2(1, closedDoorHeight/doorHeight)
			collisionShape.scale += scaleChange*startingFrame
			collisionShape.position = Vector2(16, closedDoorHeight/2)
			collisionShape.position += positionChange*startingFrame
		DoorState.CLOSED, DoorState.OPENING:
			collisionShape.scale = Vector2(1, 1)
			collisionShape.scale -= scaleChange*startingFrame
			collisionShape.position = Vector2(16, doorHeight/2)
			collisionShape.position -= positionChange*startingFrame

func onDoorSpriteFrameChanged():
	var currFrame = doorSprite.get_frame()
	match currState:
		DoorState.CLOSING:
			collisionShape.scale += scaleChange
			collisionShape.position += positionChange
			if currFrame == doorFrameCount-1:
				changeState(DoorState.CLOSED)
		DoorState.OPENING:
			collisionShape.scale -= scaleChange
			collisionShape.position -= positionChange
			if currFrame == doorFrameCount-1:
				changeState(DoorState.OPEN)
