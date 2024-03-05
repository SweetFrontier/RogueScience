extends RigidBody2D
class_name SodaBall

signal SPLATTED(gTransform : Transform2D)

# Constants
@export var LAUNCH_SPEED: float
@export var SPLAT_INTERVAL: int

var currState : SodaBallState = SodaBallState.IDLE
var startingTransform : Transform2D
var splatProgress : int = 0
var parent

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

func splat():
	SPLATTED.emit(get_global_transform())

func _integrate_forces(state):
	if currState == SodaBallState.RESETTING:
		gravity_scale = 0
		state.set_transform(startingTransform)
		state.set_linear_velocity(Vector2())
		state.set_angular_velocity(0.0)
		currState = SodaBallState.IDLE
		
	if currState == SodaBallState.LAUNCHING:
		state.set_linear_velocity(Vector2(0,-1).rotated(global_rotation)*LAUNCH_SPEED)
		state.set_angular_velocity(0.0)
		gravity_scale = 1
		$CollisionShape2D.set_deferred("disabled", false)
		$SodaBallSprite.visible = true
		currState = SodaBallState.FLYING
		
	if currState == SodaBallState.FLYING:
		splatProgress += 1
		if splatProgress >= SPLAT_INTERVAL:
			splatProgress = 0
			splat()
		for collider in get_colliding_bodies():
			print("collided")
			#check if collided with player
			var player : rigidPlayer = collider as rigidPlayer
			if(player):
				player.killFella()
			var mObject : movingObject = collider as movingObject
			if(mObject):
				mObject.destroy()
			currState = SodaBallState.EXPLODING
			gravity_scale = 0
			state.set_linear_velocity(Vector2())
			state.set_angular_velocity(0.0)
			$SodaBallSprite.visible = false
			$CollisionShape2D.set_deferred("disabled", true)
			$Explosion.play()
