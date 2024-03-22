extends Node2D
class_name baseTrigger

signal remove_key_signal(caller:baseTrigger,keyNum:int)
signal randomize_block_keys_signal

# Exported variables for customization in the editor.
@export var startActivated = false  # Whether the trigger is initially active.
@export var one_shot = true
@export var button = KEY_SPACE  # The associated button to activate the trigger.
@export var TriggerKeySprite: AnimatedSprite2D
@export var button_fade_duration: float = 2.0  # Adjust the duration as needed
var activated = false
var startingTranslucency = 0.85
var button_fade_timer: float = 0.0
var buttonToAnimation = {
	KEY_0: "0",
	KEY_1: "1",
	KEY_2: "2",
	KEY_3: "3",
	KEY_4: "4",
	KEY_5: "5",
	KEY_6: "6",
	KEY_7: "7",
	KEY_8: "8",
	KEY_9: "9",
	KEY_A: "a",
	KEY_B: "b",
	KEY_C: "c",
	KEY_D: "d",
	KEY_E: "e",
	KEY_F: "f",
	KEY_G: "g",
	KEY_H: "h",
	KEY_I: "i",
	KEY_J: "j",
	KEY_K: "k",
	KEY_L: "l",
	KEY_M: "m",
	KEY_N: "n",
	KEY_O: "o",
	KEY_P: "p",
	KEY_Q: "q",
	KEY_R: "r",
	KEY_S: "s",
	KEY_T: "t",
	KEY_U: "u",
	KEY_V: "v",
	KEY_W: "w",
	KEY_X: "x",
	KEY_Y: "y",
	KEY_Z: "z",
}

#Variables for bringing the interacting body into the trigger object
@export_group("Move Rider")
@export var moveRiderTime: float = 1
var occupied: bool = false
var ridingBody
var riderInPosition: bool = false
var beginRiderPos: Vector2
var endRiderPos: Vector2
var moveRiderProgress: float = 0.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	# Connect the input event to the `_input` method.
	set_process_input(true)
	set_button(button)

func hide_key():
	TriggerKeySprite.hide()

func _input(event):
	# Check if the associated button is pressed and the trigger is active.
	if event is InputEventKey and event.keycode == button and event.pressed and !activated and event.echo == false:
		react()  # Call the react method when the button is pressed.
		emit_signal("remove_key_signal",self,button)
		emit_signal("randomize_block_keys_signal")

# Override this method in child classes to define trigger-specific behavior.
func react():
	if !(one_shot and activated):
		# Set the key to the "pressed state"
		TriggerKeySprite.frame = 1
		# Start the fade timer.
		button_fade_timer = button_fade_duration

func reset():
	TriggerKeySprite.show()
	activated = false
	# Set the key to the "unpressed state"
	TriggerKeySprite.frame = 0
	# Reset the fade timer and opacity.
	button_fade_timer = 0.0
	TriggerKeySprite.modulate.a = startingTranslucency
	occupied = false
	ridingBody = null
	riderInPosition = false
	moveRiderProgress = 0
	
func _physics_process(delta):
	if button_fade_timer > 0.0:
		# Calculate the new opacity based on the elapsed time and fade duration.
		var new_opacity = lerpf(startingTranslucency, 0, 1.0 - (button_fade_timer / button_fade_duration))
		TriggerKeySprite.modulate.a = new_opacity
		# Decrease the fade timer.
		button_fade_timer -= delta

func set_button(_button):
	if activated:
		return
	if _button in buttonToAnimation:
		button = _button
		TriggerKeySprite.animation = buttonToAnimation[button]
	else:
		TriggerKeySprite.animation = "default"

func moveRiderToStarting(delta):
	moveRiderProgress += delta
	ridingBody.set_body_pos((endRiderPos - beginRiderPos) * (moveRiderProgress/moveRiderTime) + beginRiderPos)
	# Check if the interpolation is complete.
	if moveRiderProgress >= moveRiderTime:
		ridingBody.set_body_pos(endRiderPos)
		riderReady()

func override_movement(body):
	occupied = true
	ridingBody = body
	if ridingBody.has_method("movement_overwritten"):
		ridingBody.movement_overwritten(self)
	setupMoveToStart()

func setupMoveToStart():
	beginRiderPos = ridingBody.global_position
	riderInPosition = false
	moveRiderProgress = 0.0

func free_movement():
	if ridingBody.has_method("free_movement"):
		ridingBody.free_movement()
	ridingBody = null
	occupied = false
	
func riderReady():
	riderInPosition = true
