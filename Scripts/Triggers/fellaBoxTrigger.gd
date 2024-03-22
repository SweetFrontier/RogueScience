extends baseTrigger
class_name fellaBoxTrigger

@export var area2D: Area2D
@export var doorSprite: AnimatedSprite2D
@export var magneticBox: movingObject

var rider_freeable = false
var currState: BoxState = BoxState.OPEN

enum BoxState
{
	OPEN,
	RIDING,
	EXPLODED
}

var stateToAnimString = {
	BoxState.OPEN: "open",
	BoxState.RIDING: "riding",
	BoxState.EXPLODED: "exploded"
}

func _input(event):
	# Check if the associated button is pressed and the trigger is active.
	if event is InputEventKey and event.keycode == button and event.pressed and currState == BoxState.RIDING and !activated and event.echo == false:
		react()  # Call the react method when the button is pressed.
		emit_signal("remove_key_signal",self,button)
		emit_signal("randomize_block_keys_signal")

func _ready():
	super._ready()
	area2D.body_entered.connect(_on_body_entered)
	TriggerKeySprite.rotation_degrees = -rotation_degrees
	reset()

func react():
	super.react()
	if !activated:
		activated = true
		magneticBox.destroy()
		doorSprite.hide()
		currState = BoxState.EXPLODED
		doorSprite.animation = stateToAnimString[currState]
		ridingBody.set_collision_layer_value(1, true)
		ridingBody.set_collision_layer_value(9, true)
		ridingBody.set_collision_mask_value(1, true)
		ridingBody.set_collision_mask_value(9, true)
		free_movement()
		

func reset():
	super.reset()
	area2D.monitoring = true
	currState = BoxState.OPEN
	doorSprite.animation = stateToAnimString[currState]
	doorSprite.show()

func _process(_delta):
	TriggerKeySprite.global_rotation = 0
	TriggerKeySprite.global_position = global_position + Vector2(0,56)

func _physics_process(delta):
	super._physics_process(delta)
	if !occupied:
		return
	#ridingBody.rotate_player_on_arc(delta)
	ridingBody.set_body_pos(global_position)
	if !riderInPosition:
		moveRiderToStarting(delta)
	#else:
		#if ridingBody.is_on_floor() and rider_freeable:
		#	free_movement()

func _on_body_entered(body):
	if !body is rigidPlayer:
		return
	if !activated and !occupied and body != self:
		body.set_collision_layer_value(1, false)
		body.set_collision_layer_value(9, false)
		body.set_collision_mask_value(1, false)
		body.set_collision_mask_value(9, false)
		override_movement(body)
		if abs(body.global_position.x-global_position.x) <= 5:
			body.set_body_pos(global_position)
			riderReady()
		else:
			setupMoveToStart()
		rider_freeable = false
	
func setupMoveToStart():
	super.setupMoveToStart()
	#endRiderPos = position + MoveToPosition.global_position
	endRiderPos = global_position
	doorSprite.frame = 1

func riderReady():
	super.riderReady()
	ridingBody.positioningRideEnded(false)
	currState = BoxState.RIDING
	doorSprite.animation = stateToAnimString[currState]
	#ridingBody.add_to_cont_vel(0.0, Vector2(0, -jump_force).rotated(deg_to_rad(rotation_degrees)))
	if rotation_degrees*ridingBody.current_direction.x < 0:
		ridingBody.current_direction = -ridingBody.current_direction
		ridingBody.AnimatedSprite.flip_h = !ridingBody.AnimatedSprite.flip_h
		ridingBody.PlayerCollision.scale.x *= -1
		ridingBody.wallCast.scale *= -1
		ridingBody.AnimatedSprite.offset.x += 8*ridingBody.PlayerCollision.scale.x
	rider_freeable = false
