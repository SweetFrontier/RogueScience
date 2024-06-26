extends CharacterBody2D
class_name boss

@export var speed = 6000.0
@export var stickyMultiplier = 0.5
@export var lurchAmount = 2000
@export var decayAmount = 1000
@export var currState : BossState
@export var explodablePolygon : explodeablePolygon

@export var spriteAnim: AnimatedSprite2D
@export var lightningAnim: AnimatedSprite2D
@export var collisionShape: CollisionShape2D
@export var frontDetector: Area2D
@export var arcDetector: Area2D
@export var lightningScene: PackedScene
@export var bossSounds : AudioStreamPlayer2D
@export var zappySound : AudioStreamPlayer2D

var currDirection = Vector2.RIGHT
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 5
var inSoda : int = 0
var gravity_scale = 1

var eatingCollision
var eatingTarget 

#Electricity values
var isCharged = false
var makeLightning : bool = false
@export var secPerStrike: float = 0.05
var secSinceStrike : float = 0
var inUseLightnings : Array[lightningBolt]
var unusedLightnings : Array[lightningBolt]
var conductiveBodies : Array[Node2D]
var fansInRange : Array[fanTrigger]

#Fan Values
@export var maxSingleFanVelocity: float = 100.0
@export var maxFanVelocity: float = 20.0
var fanConst = 350

enum BossState
{
	CHASING,
	EATING,
	BEINGCONTROLLED
}

const rawr = preload("res://Sounds/boss/rawr.ogg")
const munch = preload("res://Sounds/boss/swollow.ogg")
const crushed = preload("res://Sounds/death.ogg")

func _ready():
	currState = BossState.BEINGCONTROLLED

func reset():
	currState = BossState.BEINGCONTROLLED
	playAnimation("chasing")
	currDirection = Vector2.RIGHT
	collisionShape.position.x = 56
	frontDetector.position.x = 56
	frontDetector.scale.x = 1
	spriteAnim.flip_h = false
	velocity = Vector2(0,0)
	eatingTarget = null
	eatingCollision = null
	inSoda = 0
	setBossCharge(false)

func _physics_process(delta):
	gravity_scale = 1.0
	if inSoda < 0:
		inSoda = 0
	elif inSoda >= 1:
		gravity_scale = stickyMultiplier
	
	if(currState == BossState.CHASING):
		# Add the gravity.
		if not is_on_floor():
			velocity.y += gravity * delta * gravity_scale
		if is_on_wall():
			currDirection.x = -currDirection.x
			collisionShape.position.x = -collisionShape.position.x
			frontDetector.position.x = -frontDetector.position.x
			frontDetector.scale.x = -frontDetector.scale.x
			spriteAnim.flip_h = !spriteAnim.flip_h
		velocity.x = currDirection.x * speed * delta * gravity_scale
		velocity += calc_fan_forces(fansInRange) * fanConst * delta * gravity_scale
		move_and_slide()
	elif(currState == BossState.EATING):
		if velocity.x > 0:
			velocity.x = max(velocity.x - decayAmount * delta, 0)
		elif velocity.x < 0:
			velocity.x = min(velocity.x + decayAmount * delta, 0)
		move_and_slide()

func _process(delta):
	if(makeLightning):
		secSinceStrike += delta
		if secSinceStrike >= secPerStrike:
			for l in inUseLightnings:
				l.lightning_strike()
			secSinceStrike = 0

func changeDirection(direction : Vector2):
	currDirection = direction
	if currDirection == Vector2.RIGHT:
		collisionShape.position.x = 56
		frontDetector.position.x = 56
		frontDetector.scale.x = 1
		spriteAnim.flip_h = false
	if currDirection == Vector2.LEFT:
		collisionShape.position.x = -56
		frontDetector.position.x = -56
		frontDetector.scale.x = -1
		spriteAnim.flip_h = true

func hitSomethingEatable(body):
	if not body is rigidPlayer and not body is movingObject and not body is Bullet and not body is SodaBall:
		var bodyParent = body.get_parent()
		if not bodyParent is breakableBlocks and not bodyParent is invisibleBlock:
			return
		eatingCollision = body
		body = bodyParent
	#If player is dead, don't eat them
	if body is rigidPlayer and body.dead == true:
		return
	spriteAnim.play("eating")
	eatingTarget = body
	if eatingTarget is rigidPlayer or eatingTarget is movingObject:
		eatingTarget.set_body_pos(eatingTarget.global_position)
		eatingTarget.movement_overwritten(self)
		eatingTarget.set_collision_layer_value(1, false)
		eatingTarget.set_collision_mask_value(1, false)
	elif eatingTarget is breakableBlocks or eatingTarget is invisibleBlock:
		eatingCollision.collision_layer = 0
		eatingCollision.collision_mask = 0
	elif eatingTarget is Bullet:
		eatingTarget.explode()
	elif eatingTarget is SodaBall:
		eatingTarget.reset()
	currState = BossState.EATING
	velocity.x = lurchAmount * currDirection.x
	bossSounds.stream = munch
	bossSounds.volume_db = 5
	bossSounds.play()
	
func hitSomethingEatableArea(_area_rid, area, _area_shape_index, _local_shape_index):
	hitSomethingEatable(area)

func onAnimationFinished():
	if spriteAnim.animation == "eating":
		if eatingTarget is rigidPlayer:
			eatingTarget.isShielded = false
			eatingTarget.SodaShield.visible = false
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
	elif spriteAnim.animation == "growling":
		playAnimation("chasing")
		currState = BossState.CHASING

func playAnimation(animation):
	spriteAnim.play(animation)

#Power-based functions
#Why yes, this was just ripped from Electrode.gd

func setBossCharge(charged : bool = false, frame : int = 0):
	isCharged = charged
	if isCharged:
		lightningAnim.frame = frame
		lightningAnim.play()
		lightningAnim.show()
	else:
		lightningAnim.stop()
		lightningAnim.hide()

func resetLightning():
	for cb in conductiveBodies:
		if cb is magneticObject:
			cb.endEnergyChain()
	conductiveBodies.clear()
	for l in inUseLightnings:
		l.hide_lightning()
		unusedLightnings.append(l)
	inUseLightnings.clear()
	makeLightning = false

func onLightningSpriteFrameChanged():
	if lightningAnim.frame == 3:
		outputElectrode()
	elif lightningAnim.frame == 6:
		resetLightning()

func outputElectrode():
	conductiveBodies = arcDetector.get_overlapping_bodies()
	var cBodies = arcDetector.get_overlapping_bodies()
	for cb in cBodies:
		if cb == self:
			continue
		elif cb is electrode or cb is magneticObject:
			if cb.currState == cb.PowerState.ON or (cb is electrode and (cb.locked or (cb.activated and cb.one_shot))):
				continue
			conductiveBodies.append(cb)
			var lightning = getFreeLightning()
			lightning.toPos = cb
			lightning.lightning_strike()
			makeLightning = true
			zappySound.play()
			secSinceStrike = 0
			lightning.show_lightning()
			cb.power(self)

func getFreeLightning():
	var freeLightning = unusedLightnings.pop_back()
	if !freeLightning:
		freeLightning = lightningScene.instantiate()
		freeLightning.fromPos = self
		freeLightning.rotation = -rotation
		add_child(freeLightning)
	inUseLightnings.append(freeLightning)
	return freeLightning	

#Fan functions

func calc_fan_forces(fans:Array[fanTrigger]):
	var fan_linear_velocity = Vector2()
	for fan in fans:
		var distance = global_position.distance_to(fan.global_position)
		var force = fan.strength/distance
		fan_linear_velocity += (fan.direction * force).clamp(Vector2(-maxSingleFanVelocity,-maxSingleFanVelocity), Vector2(maxSingleFanVelocity,maxSingleFanVelocity))
	fan_linear_velocity = fan_linear_velocity.clamp(Vector2(-maxFanVelocity,-maxFanVelocity), Vector2(maxFanVelocity,maxFanVelocity))
	return fan_linear_velocity

#Sound functions

func do_the_roar(pitch:float=1.0):
	bossSounds.stream = rawr
	bossSounds.pitch_scale = pitch
	bossSounds.volume_db = 0
	bossSounds.play()

func play_crushed_sound(pitch:float=1.0):
	bossSounds.stream = crushed
	bossSounds.pitch_scale = pitch
	bossSounds.volume_db = 20
	bossSounds.play()
