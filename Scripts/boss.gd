extends CharacterBody2D
class_name boss

@export var speed = 6000.0
@export var stickyMultiplier = 0.5
@export var lurchAmount = 2000
@export var decayAmount = 1000
var currDirection = Vector2.RIGHT
@export var currState : BossState
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 5

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
	collision_layer = 1
	collision_mask = 1
	playAnimation("chasing")
	
	velocity = Vector2(0,0)
	eatingTarget = null

func _physics_process(delta):
	if(currState == BossState.CHASING):
		# Add the gravity.
		if not is_on_floor():
			velocity.y += gravity * delta
		
		if is_on_wall():
			currDirection.x = -currDirection.x
		
		velocity.x = currDirection.x * speed * delta
		move_and_slide()
	elif(currState == BossState.EATING):
		velocity.x -= decayAmount*delta
		velocity.x = max(velocity.x, 0)
		move_and_slide()

func hitSomethingEatable(body):
	if not body is rigidPlayer and not body is movingObject:
		return
	$AnimatedSprite2D.play("eating")
	collision_layer = 0
	collision_mask = 0
	
	eatingTarget = body
	eatingTarget.set_body_pos(eatingTarget.global_position)
	eatingTarget.movement_overwritten(self)
	currState = BossState.EATING
	velocity.x = lurchAmount

func onAnimationFinished():
	if $AnimatedSprite2D.animation == "eating":
		if eatingTarget is rigidPlayer:
			eatingTarget.killFella()
		elif eatingTarget is movingObject:
			eatingTarget.destroy()
		eatingTarget = null
		
		collision_layer = 1
		collision_mask = 1
		playAnimation("chasing")
		currState = BossState.CHASING

func playAnimation(animation):
	$AnimatedSprite2D.play(animation)
