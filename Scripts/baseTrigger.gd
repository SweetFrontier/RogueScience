extends Node2D
class_name baseTrigger

# Exported variables for customization in the editor.
@export var activated = false  # Whether the trigger is initially active.
@export var button = KEY_SPACE  # The associated button to activate the trigger.
@export var TriggerKeySprite: AnimatedSprite2D
@export var fade_duration: float = 2.0  # Adjust the duration as needed
@export var one_shot = true
var fade_timer: float = 0.0
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

func _ready():
	# Connect the input event to the `_input` method.
	set_process_input(true)
	set_button(button)

func _input(event):
	# Check if the associated button is pressed and the trigger is active.
	if event is InputEventKey and event.keycode == button and event.pressed:
		react()  # Call the react method when the button is pressed.

# Override this method in child classes to define trigger-specific behavior.
func react():
	if !(one_shot and activated):
		# Set the key to the "pressed state"
		TriggerKeySprite.frame = 1
		# Start the fade timer.
		fade_timer = fade_duration

func reset():
	# Set the key to the "unpressed state"
	TriggerKeySprite.frame = 0
	# Reset the fade timer and opacity.
	fade_timer = 0.0
	TriggerKeySprite.modulate.a = 1
	
func _physics_process(delta):
	if fade_timer > 0.0:
		# Calculate the new opacity based on the elapsed time and fade duration.
		var new_opacity = lerp(1, 0, 1.0 - (fade_timer / fade_duration))
		TriggerKeySprite.modulate.a = new_opacity
		# Decrease the fade timer.
		fade_timer -= delta

func set_button(_button):
	if _button in buttonToAnimation:
		button = _button
		TriggerKeySprite.animation = buttonToAnimation[button]
	else:
		TriggerKeySprite.animation = "default"
