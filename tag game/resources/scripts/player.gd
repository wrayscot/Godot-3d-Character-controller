extends CharacterBody2D

@export_category("Player Settings")
@export var player = 0
@export var maxHealth = 100

signal shootSignal

@onready var directionArrow = $"direction arrow"
@onready var shotgun = $"shotgun"
@onready var dashHitbox = $"shotgun/Area2D"
@onready var healthBar = $"healthBar"

const SPEED = 600.0
const FRICTION = .03
const JUMP_VELOCITY = -400.0

var health = maxHealth
var maxDashes = 100
var availableDashes = maxDashes
var dashCooldown = 20
var dashTimeleft = dashCooldown

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	healthBar.value = health
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_on_floor():
		availableDashes = maxDashes
		velocity.x = lerp(velocity.x, 0.0, FRICTION)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	var Direction = calc_direction()
	
	update_arrow(Direction)
	
	Direction *= SPEED

	if is_on_wall() or is_on_ceiling():
		availableDashes = maxDashes
		
	if Input.get_action_raw_strength("dash") and availableDashes > 0 and dashTimeleft <= 0:
		availableDashes -= 1
		velocity /= 10
		velocity += Direction
		dashTimeleft = dashCooldown
		shootSignal.emit()
		
		for body in dashHitbox.get_overlapping_bodies():
			if body.is_in_group("players"):
				body.damage()
				
	dashTimeleft -= 1

	if health < 0:
		print("fd")

	move_and_slide()

func damage():
	health -= 25

func _in

func calc_direction():
	var xDirection = Input.get_action_raw_strength("right") - Input.get_action_raw_strength("left")
	var yDirection = Input.get_action_raw_strength("down") - Input.get_action_raw_strength("up")
	if Input.get_connected_joypads() != []:
		xDirection = Input.get_joy_axis(player, JOY_AXIS_LEFT_X)
		yDirection = Input.get_joy_axis(player, JOY_AXIS_LEFT_Y)
	var Direction = Vector2(xDirection, yDirection)
	return Direction

func update_arrow(direction):
	var arrowDegree = vector_to_degree(direction)
	var shotgunDegree = vector_to_degree(-direction) - deg_to_rad(90)
	directionArrow.global_rotation = arrowDegree
	shotgun.global_rotation = shotgunDegree
	
	var arrowScale = direction.distance_to(Vector2(0, 0)) + 1
	directionArrow.scale = Vector2(1, arrowScale)

func vector_to_degree(vector):
	var degree = atan2(vector.x, -vector.y)
	return degree
		


