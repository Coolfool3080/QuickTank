extends CharacterBody3D

const MOVE_SPEED = 5
const ROTATION_SPEED = 1

@export var Bullet: PackedScene

func _physics_process(delta):
	if not is_multiplayer_authority():
		return

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Tank head look angle
	var tank_head = get_parent().get_node("tank/tank_head_phys_box")
	var look_pos = get_parent().get_node("tank/camera_controller/look_node").global_position
	
	tank_head.look_at(look_pos)

	# Input
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

# shoot 
func _input(event):
	if event.is_action_pressed("shoot"):
		shoot()

func shoot():
	var bullet = Bullet.instantiate()
	bullet.global_transform = $tank_head_phys_box/bullet_spawn_point.global_transform
	get_tree().current_scene.add_child(bullet)
