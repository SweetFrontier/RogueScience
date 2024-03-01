extends baseTrigger

class_name securityCameraTrigger

@export var secondsToSetup: float
@export var cameraView: Area2D
@export var cameraSprite: AnimatedSprite2D
@export var gunSprite: AnimatedSprite2D

var currState: SecurityCameraState = SecurityCameraState.INACTIVE
var startingPivotRotation: float
var pivotProgress: float = 0
var targetIdentified: bool = false

enum SecurityCameraState
{
	INACTIVE,
	MOVINGTOPOSITION,
	INPOSITION,
	SHUTTINGDOWN
}


# Called when the node enters the scene tree for the first time.
func _ready():
	cameraView.body_entered.connect(_on_camera_caught)
	startingPivotRotation = $CameraPivotPoint.rotation_degrees
	$CameraPivotPoint/CameraView/Polygon2D.visible = false
	$CameraPivotPoint.rotation_degrees = 270
	currState = SecurityCameraState.INACTIVE
	reset()

func react():
	super.react()
	if !activated:
		activated = true
		if currState == SecurityCameraState.INPOSITION:
			cameraView.monitoring = true
			cameraSprite.animation = "activated"
			cameraSprite.frame = 0
			gunSprite.animation = "default"
			gunSprite.frame = 0
			$CameraPivotPoint.rotation_degrees = startingPivotRotation
			$CameraPivotPoint/CameraView/Polygon2D.visible = true
		else:
			pivotProgress = 0
			currState = SecurityCameraState.MOVINGTOPOSITION

func reset():
	super.reset()
	cameraView.monitoring = false
	cameraSprite.animation = "deactivated"
	gunSprite.animation = "default"
	gunSprite.frame = 0
	pivotProgress = 0
	$CameraPivotPoint.rotation_degrees = 270
	$CameraPivotPoint/CameraView/Polygon2D.visible = false
	targetIdentified = false
	$GunSprite/Bullet.reset()
	currState = SecurityCameraState.INACTIVE
	if startActivated:
		currState = SecurityCameraState.INPOSITION
		react()
		button_fade_timer = 0
		TriggerKeySprite.modulate.a = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match(currState):
		SecurityCameraState.MOVINGTOPOSITION:
			pivotProgress += delta / secondsToSetup
			if pivotProgress < 1:
				$CameraPivotPoint.rotation = lerp_angle(deg_to_rad(270), deg_to_rad(startingPivotRotation), pivotProgress)
			else:
				cameraView.monitoring = true
				cameraSprite.animation = "activated"
				cameraSprite.frame = 0
				gunSprite.animation = "default"
				gunSprite.frame = 0
				$CameraPivotPoint/CameraView/Polygon2D.visible = true
				$CameraPivotPoint.rotation_degrees = startingPivotRotation
				currState = SecurityCameraState.INPOSITION
		SecurityCameraState.SHUTTINGDOWN:
			pivotProgress += delta / secondsToSetup
			if pivotProgress < 1:
				$CameraPivotPoint.rotation = lerp_angle(deg_to_rad(startingPivotRotation), deg_to_rad(270), pivotProgress)
			else:
				$CameraPivotPoint.rotation_degrees = 270
				currState = SecurityCameraState.INACTIVE

func _on_camera_caught(body):
	if !body is movingObject and !body is rigidPlayer:
		return
	targetIdentified = true
	cameraView.set_deferred("monitoring",false)# = false
	cameraSprite.animation = "deactivated"
	gunSprite.animation = "default"
	$CameraPivotPoint/CameraView/Polygon2D.visible = false
	$GunSprite/Bullet.setTarget(body)
	$GunSprite/Bullet.launch()
	pivotProgress = 0
	currState = SecurityCameraState.SHUTTINGDOWN
