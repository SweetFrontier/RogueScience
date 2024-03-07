extends CharacterBody2D
class_name Bullet

# Constants
@export var stickyMultiplier = 0.5
@export var MAX_ROTATION_SPEED = 30
@export var BULLET_SPEED = 10.0

@export var bulletState : BulletState = BulletState.IDLE
var target_node : Node2D = null

var startingTransform : Transform2D
var inSoda : int = 0

enum BulletState
{
	IDLE,
	ABOUTTOLAUNCH,
	FLYING,
	EXPLODING,
	EXPLODED
}

func _ready():
	$Explosion.animation_finished.connect(explosionFinished)
	startingTransform = get_transform()

func reset():
	$BulletSprite.visible = true
	bulletState = BulletState.IDLE
	transform = startingTransform
	velocity = Vector2(0,0)
	inSoda = 0
	$CollisionShape2D.set_deferred("disabled", false)

func setTarget(target: Node2D):
	target_node = target

func launch():
	bulletState = BulletState.FLYING

func _process(delta):
	match(bulletState):
		BulletState.FLYING:
			var gravity_scale = 1.0
			if inSoda < 0:
				inSoda = 0
			elif inSoda >= 1:
				gravity_scale = stickyMultiplier
			global_rotation = lerp_angle(global_rotation, (target_node.global_position - global_position).angle(), delta * MAX_ROTATION_SPEED * stickyMultiplier)
			velocity = (Vector2(1,0) * BULLET_SPEED * delta * gravity_scale).rotated(global_rotation)
			move_and_slide()
			
			#if collided with something
			for i in get_slide_collision_count():
				var collision = get_slide_collision(i)
				var collider = collision.get_collider()
				
				#check if collided with player
				var player : rigidPlayer = collider as rigidPlayer
				if(player):
					player.killFella()
				var mObject : movingObject = collider as movingObject
				if(mObject):
					mObject.destroy()
				bulletState = BulletState.EXPLODING
				$BulletSprite.visible = false
				$CollisionShape2D.set_deferred("disabled", true)
				$Explosion.play()

func explosionFinished():
	bulletState = BulletState.EXPLODED
