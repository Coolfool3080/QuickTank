extends CharacterBody3D

const MOVE_SPEED = 5
const ROTATION_SPEED = 1

func _physics_process(delta):
	if not is_multiplayer_authority():
		return
	
	var direction = Vector3.ZERO
	
	if Input.is_action_pressed("tank_rotate_right"):
		rotate_y(-.05)
	if Input.is_action_pressed("tank_rotate_left"):
		rotate_y(.05)
	if Input.is_action_pressed("tank_backward"):
		velocity.z += 1
	if Input.is_action_pressed("tank_forward"):
		velocity.z -= 1
	
	if velocity != Vector3.ZERO:
		velocity = velocity.normalized() * MOVE_SPEED
	
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	move_and_slide()
