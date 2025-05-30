extends CharacterBody3D

@onready var camera_pivot = $camera_pivot
@onready var head_node = $head

const MOVE_SPEED = 5.0
const ROTATION_SPEED = 1.5
const CAMERA_SENSITIVITY = 0.001
const HEAD_ROTATE_SPEED = 1.0

var camera_yaw = 0.0

func _ready():
	$camera_pivot/Camera3D.current = is_multiplayer_authority()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		camera_yaw -= event.relative.x * CAMERA_SENSITIVITY
		camera_pivot.rotation.y = camera_yaw

func _physics_process(delta):
	if not is_multiplayer_authority():
		return

	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	else:
		velocity.y = 0

	var turn_input = Input.get_axis("tank_rotate_right", "tank_rotate_left")
	if turn_input != 0:
		rotate_y(turn_input * ROTATION_SPEED * delta)

	var move_input = Input.get_axis("tank_backward", "tank_forward")
	if move_input != 0:
		var forward = -global_transform.basis.z.normalized()
		velocity.x = forward.x * MOVE_SPEED * move_input
		velocity.z = forward.z * MOVE_SPEED * move_input
	else:
		velocity.x = move_toward(velocity.x, 0, MOVE_SPEED/2 * delta)
		velocity.z = move_toward(velocity.z, 0, MOVE_SPEED/2 * delta)

	move_and_slide()

	# Rotate head relative to tank's local space
	var tank_basis = global_transform.basis
	var camera_global_yaw = camera_pivot.global_transform.basis.get_euler().y
	var tank_yaw = tank_basis.get_euler().y
	var relative_yaw = camera_global_yaw - tank_yaw

	head_node.rotation.y = lerp_angle(head_node.rotation.y, relative_yaw, delta * HEAD_ROTATE_SPEED)
