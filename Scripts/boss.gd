extends CharacterBody2D
class_name boss

@export var speed = 6000.0
@export var stickyMultiplier = 0.5
@export var lurchAmount = 2000
@export var decayAmount = 1000
@export var currState : BossState

@export var spriteAnim: AnimatedSprite2D
@export var collisionShape: CollisionShape2D
@export var frontDetector: Area2D

var currDirection = Vector2.RIGHT
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 5

var eatingCollision
var eatingTarget 

enum BossState
{
	CHASING,
	EATING,
	BEINGCONTROLLED
}

func _ready():
	currState = BossState.BEINGCONTROLLED

func reset():
	currState = BossState.BEINGCONTROLLED
	playAnimation("chasing")
	currDirection = Vector2.RIGHT
	collisionShape.position.x = 56
	frontDetector.position.x = 56
	spriteAnim.flip_h = false
	velocity = Vector2(0,0)
	eatingTarget = null
	eatingCollision = null

func _physics_process(delta):
	if(currState == BossState.CHASING):
		# Add the gravity.
		if not is_on_floor():
			velocity.y += gravity * delta
		
		if is_on_wall():
			currDirection.x = -currDirection.x
			collisionShape.position.x = -collisionShape.position.x
			frontDetector.position.x = -frontDetector.position.x
			spriteAnim.flip_h = !spriteAnim.flip_h
		velocity.x = currDirection.x * speed * delta
		move_and_slide()
	elif(currState == BossState.EATING):
		if velocity.x > 0:
			velocity.x = max(velocity.x - decayAmount * delta, 0)
		elif velocity.x < 0:
			velocity.x = min(velocity.x + decayAmount * delta, 0)
		move_and_slide()

func hitSomethingEatable(body):
	if not body is rigidPlayer and not body is movingObject:
		var bodyParent = body.get_parent()
		if not bodyParent is breakableBlocks and not bodyParent is invisibleBlock:
			return
		eatingCollision = body
		body = bodyParent
	
	spriteAnim.play("eating")
	
	eatingTarget = body
	if eatingTarget is rigidPlayer or eatingTarget is movingObject:
		eatingTarget.set_body_pos(eatingTarget.global_position)
		eatingTarget.movement_overwritten(self)
		eatingTarget.set_collision_layer_value(1, false)
		eatingTarget.set_collision_mask_value(1, false)
	else:
		eatingCollision.collision_layer = 0
		eatingCollision.collision_mask = 0
	currState = BossState.EATING
	velocity.x = lurchAmount * currDirection.x

func onAnimationFinished():
	if spriteAnim.animation == "eating":
		if eatingTarget is rigidPlayer:
			eatingTarget.killFella()
		elif eatingTarget is movingObject:
			eatingTarget.destroy()
		elif eatingTarget is breakableBlocks:
			eatingTarget.destroy(false)
		elif eatingTarget is invisibleBlock:
			eatingTarget.destroy()
		eatingTarget = null
		eatingCollision = null
		
		playAnimation("chasing")
		currState = BossState.CHASING

func playAnimation(animation):
	spriteAnim.play(animation)
