extends CharacterBody3D

const MOVE_SPEED = 5
const ROTATION_SPEED = 1

func _physics_process(delta):
	#Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#var tank_head = get_parent().get_node("tank/tank_head")
	#var look_position = get_parent().get_node("tank/camera_controller/look_node").global_position

	var rotation_dir = Input.get_axis("tank_rotate_right", "tank_rotate_left")

	if Input.is_action_pressed("tank_forward"):
		rotate_y(rotation_dir * delta)
		velocity = global_transform.basis.z.normalized() * MOVE_SPEED
	elif Input.is_action_pressed("tank_backward"):
		rotate_y(-rotation_dir * delta)
		velocity = -global_transform.basis.z.normalized() * MOVE_SPEED
	else:
		rotate_y(rotation_dir * delta)
		velocity.x = move_toward(velocity.x, 0, MOVE_SPEED)
		velocity.z = move_toward(velocity.z, 0, MOVE_SPEED)

	move_and_slide()
