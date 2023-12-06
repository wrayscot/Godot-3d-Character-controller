extends CharacterBody3D

@onready var head = $"head"

var cam_x = 0.0
var cam_y = 0.0
#highest you can look up or down
var cam_x_max = 75.0
var cam_x_min = -70.0

#mouse sens, higher equals faster mouse turns
var y_sensitivity = 10.0
var x_sensitivity = 10.0
var y_acceleration = 10
var x_acceleration = 10

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		cam_y += -event.relative.x * y_sensitivity
		cam_x += -event.relative.y * x_sensitivity

func _physics_process(delta):
	
	#highest you can look up or down
	cam_x = clamp(cam_x, cam_x_min, cam_x_max)
	
	#changes the player's rotation which by extension rotates the camera
	rotation_degrees.y = lerp(head.rotation_degrees.y, cam_y, delta * y_acceleration)
	#changes camera position so the player doesn't change height or tilt weird
	head.rotation_degrees.x = lerp(head.rotation_degrees.x, cam_x, delta * x_acceleration)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
