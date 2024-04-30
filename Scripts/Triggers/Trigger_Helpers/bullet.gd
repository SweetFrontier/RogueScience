extends Area2D
class_name Bullet

# Constants
@export var stickyMultiplier = 0.5
@export var MAX_ROTATION_SPEED = 30
@export var BULLET_SPEED = 10.0

@export var bulletState : BulletState = BulletState.IDLE
var target_node : Node2D = null

var velocity : Vector2 = Vector2()
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
	$BulletSprite.visible = false
	bulletState = BulletState.IDLE
	transform = startingTransform
	velocity = Vector2()
	inSoda = 0
	$CollisionShape2D.set_deferred("disabled", true)

func setTarget(target: Node2D):
	target_node = target

func launch():
	bulletState = BulletState.FLYING
	$BulletSprite.visible = true
	$CollisionShape2D.set_deferred("disabled", false)

func _physics_process(delta):
	match(bulletState):
		BulletState.FLYING:
			var gravity_scale = 1.0
			if inSoda < 0:
				inSoda = 0
			elif inSoda >= 1:
				gravity_scale = stickyMultiplier
			global_rotation = lerp_angle(global_rotation, (target_node.global_position - global_position).angle(), delta * MAX_ROTATION_SPEED * stickyMultiplier)
			velocity = (Vector2(1,0) * BULLET_SPEED * gravity_scale).rotated(global_rotation)
			#velocity.y += gravity * gravity_scale
			global_position += velocity * delta

func explosionFinished():
	bulletState = BulletState.EXPLODED

func explode():
	bulletState = BulletState.EXPLODING
	$BulletSprite.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	$Explosion.play()

func _on_body_entered(collider):
	var colliderParent = collider.get_parent()
	if collider is rigidPlayer:
		var player = collider as rigidPlayer
		player.killFella()
	elif collider is movingObject:
		var mObject = collider as movingObject
		mObject.destroy()
	elif colliderParent and colliderParent is breakableBlocks:
		var bBlock = colliderParent as breakableBlocks
		bBlock.destroy(false)
	elif colliderParent and colliderParent is invisibleBlock:
		var iBlock = colliderParent as invisibleBlock
		iBlock.destroy()
	explode()
