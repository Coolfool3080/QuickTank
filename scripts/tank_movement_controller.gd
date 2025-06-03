extends CharacterBody3D

@onready var camera_pivot = $camera_pivot
@onready var head_node = $head
@onready var head_barrel = $head/head_mesh/barrel_pivot
@onready var fire_cooldown_timer = $fire_cooldown_timer

@export var Bullet: PackedScene

const MOVE_SPEED = 5.0
const ROTATION_SPEED = 1.5
const CAMERA_SENSITIVITY = 0.001
const HEAD_ROTATE_SPEED = 1.0

var TANK_HEALTH = 5
var camera_yaw = 0.0
var camera_pitch = 0.0

func _enter_tree() -> void:
	set_multiplayer_authority(int(name))
	
func _ready():
	if is_multiplayer_authority():
		$camera_pivot/Camera3D.current = true
		#print("Tank spawned. My ID:", multiplayer.get_unique_id())
		#print("Has authority:", is_multiplayer_authority())
	
func _unhandled_input(event):
	if not is_multiplayer_authority():
		return
	
	if event is InputEventMouseMotion:
		camera_yaw -= event.relative.x * CAMERA_SENSITIVITY
		camera_pivot.rotation.y = camera_yaw
		
		camera_pitch -= event.relative.y * CAMERA_SENSITIVITY
		camera_pivot.rotation.x = clamp(camera_pitch, -0.5, 0.5)

	
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
	
	var camera_global_yaw = camera_pivot.global_transform.basis.get_euler().y
	var tank_yaw = global_transform.basis.get_euler().y
	var relative_yaw = camera_global_yaw - tank_yaw
	
	var camera_global_pitch = camera_pivot.global_transform.basis.get_euler().x
	var tank_pitch = global_transform.basis.get_euler().x
	var relative_pitch = camera_global_pitch - tank_pitch
	
	head_node.rotation.y = lerp_angle(head_node.rotation.y, relative_yaw, delta * HEAD_ROTATE_SPEED)
	head_barrel.rotation.x = lerp_angle(head_barrel.rotation.x, relative_pitch, delta * HEAD_ROTATE_SPEED)

	#shoot
func _input(event):
	if event.is_action_pressed("shoot") and fire_cooldown_timer.is_stopped():
		shoot()
	
func shoot():
	var bullet = Bullet.instantiate()
	bullet.global_transform = $head/head_mesh/barrel_pivot/barrel_mesh/bullet_spawn_point.global_transform
	get_tree().current_scene.add_child(bullet)
	fire_cooldown_timer.start()

func _on_body_hitbox_area_entered(area):
	if not is_multiplayer_authority():
		return
	if area.is_in_group("bullet"):
		print("bullet hit body")
		$health_sprite.take_damage(1)

func _on_head_hitbox_area_entered(area):
	if not is_multiplayer_authority():
		return
	if area.is_in_group("bullet"):
		print("Bullet hit head!")
		$health_sprite.take_damage(1)
