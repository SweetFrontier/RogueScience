extends Area2D
class_name SodaBall

signal SPLATTED(gPosition : Vector2)

# Constants
@export var LAUNCH_SPEED: float
@export var SPLAT_INTERVAL: int
@export var SPLAT_RADIUS: int

var currState : SodaBallState = SodaBallState.IDLE
var startingTransform : Transform2D
var splatProgress : int = 0
var parent
var velocity : Vector2 = Vector2()
var gravity_scale = 0

enum SodaBallState
{
	RESETTING,
	IDLE,
	LAUNCHING,
	FLYING,
	EXPLODING,
	EXPLODED
}

func _ready():
	startingTransform = get_global_transform()
	parent = get_parent()
	reset()

func reset():
	currState = SodaBallState.RESETTING
	$SodaBallSprite.visible = false
	transform = startingTransform
	$CollisionShape2D.set_deferred("disabled", true)

func launch():
	currState = SodaBallState.LAUNCHING

func splat(gPosition : Vector2):
	SPLATTED.emit(gPosition)

func _physics_process(delta):
	if currState == SodaBallState.RESETTING:
		global_transform = startingTransform
		velocity = Vector2()
		gravity_scale = 0
		currState = SodaBallState.IDLE
		
	if currState == SodaBallState.LAUNCHING:
		global_transform = startingTransform
		velocity = Vector2(0,-1).rotated(get_parent().global_rotation)*LAUNCH_SPEED
		gravity_scale = 1
		$CollisionShape2D.set_deferred("disabled", false)
		$SodaBallSprite.visible = true
		splatProgress = 0
		currState = SodaBallState.FLYING
		
	if currState == SodaBallState.FLYING:
		splatProgress += 1
		if splatProgress >= SPLAT_INTERVAL:
			splatProgress = 0
			splat(get_global_position())
	velocity.y += gravity * gravity_scale * delta
	global_position += velocity * delta
	rotation = velocity.angle()+deg_to_rad(90)

func _on_body_entered(collider):
	if currState == SodaBallState.FLYING:
		var sCT = collider.get_parent().get_parent().get_parent() as securityCameraTrigger
		#check if collided with player
		if(collider is rigidPlayer):
			var player = collider as rigidPlayer
			player.GiveSodaShield()
		elif(collider is movingObject):
			var mObject = collider as movingObject
			mObject.GiveSodaShield()
		elif(collider is StaticBody2D and sCT):
			sCT.CoverInSoda()
		else:
			#default - cover surrounding tiles in goo
			for r in range(-SPLAT_RADIUS, SPLAT_RADIUS+1):
				for c in range(-SPLAT_RADIUS, SPLAT_RADIUS+1):
					if r*r+c*c <= SPLAT_RADIUS*SPLAT_RADIUS:
						splat(get_global_position()+Vector2(r,c)*32)
		currState = SodaBallState.EXPLODING
		gravity_scale = 0
		velocity = Vector2()
		$SodaBallSprite.visible = false
		$CollisionShape2D.set_deferred("disabled", true)
		$Explosion.play()
