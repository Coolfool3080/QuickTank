extends CharacterBody3D

@export var Bullet: PackedScene

@onready var head_node = $head
@onready var fast_head = $head2
@onready var head_barrel = $head/head_mesh/barrel_pivot
@onready var fast_barrel = $head2/barrel_pivot2
@onready var fire_cooldown_timer = $fire_cooldown_timer
@onready var player_camera_scene

const MOVE_SPEED = 5.0
const ROTATION_SPEED = 1.5
const HEAD_ROTATE_SPEED = 2.0
const RAY_LENGTH = 1000

var health: int = 100
var armor: int = 100
var camera_rotation: Vector2 = Vector2.ZERO
var camera: Node3D
var hud
var dead_screen

func _enter_tree() -> void:
	set_multiplayer_authority(int(name))
	
func _ready():
	if is_multiplayer_authority():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
		player_camera_scene = preload("res://assets/player_camera.tscn")
		camera = player_camera_scene.instantiate()
		get_tree().get_root().add_child(camera)
		
		camera.target = self
		camera.get_node("camera_yaw/camera_pitch/spring/Camera3D").current = true
		
		hud = preload("res://assets/tank_hud.tscn").instantiate()
		get_tree().get_root().add_child(hud)
		
		dead_screen = preload("res://assets/dead_screen.tscn").instantiate()
		#print("Tank spawned. My ID:", multiplayer.get_unique_id())
		#print("Has authority:", is_multiplayer_authority())
	
func _physics_process(delta):
	if not is_multiplayer_authority():
		return
	
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	else:
		velocity.y = 0

	var camera_yaw = camera.get_node("camera_yaw")
	var camera_pitch = camera.get_node("camera_yaw/camera_pitch")
	
	head_node.global_rotation.y = camera_yaw.global_rotation.y
	head_barrel.global_rotation.x = camera_pitch.global_rotation.x
	
	var turn_input = Input.get_axis("tank_rotate_right", "tank_rotate_left")
	if turn_input != 0:
		rotate_y(turn_input * ROTATION_SPEED * delta)
	
	var move_input = Input.get_axis("tank_backward", "tank_forward")
	if move_input != 0:
		var forward = -global_transform.basis.z.normalized()
		velocity.x = forward.x * MOVE_SPEED * move_input
		velocity.z = forward.z * MOVE_SPEED * move_input
	else:
		velocity.x = move_toward(velocity.x, 0, MOVE_SPEED * 4 * delta)
		velocity.z = move_toward(velocity.z, 0, MOVE_SPEED * 4 * delta)
	
	move_and_slide()
	
	var space_state = get_world_3d().direct_space_state
	var mouse_position = get_viewport().get_mouse_position()
	var cam = get_tree().get_root().get_node("player_camera/camera_yaw/camera_pitch/spring/Camera3D")
	
	var origin = cam.project_ray_origin(mouse_position)
	var end = origin + cam.project_ray_normal(mouse_position) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	
	var result = space_state.intersect_ray(query)
	
	if result:
		head_barrel.look_at(result.position)
	else:
		pass

	#shoot
func _input(event):
	if not is_multiplayer_authority():
		return
	
	var ammo_count: int = int(hud.get_node("ammo_number").text)
		
	if event.is_action_pressed("shoot") and fire_cooldown_timer.is_stopped() and ammo_count > 0:
		shoot.rpc()
		hud.decrease_hud_ammo()

var bullet_damage: int = 10

@rpc("call_local")
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
		$health_sprite.take_damage(bullet_damage)
		hud.update_hud_health_and_armor(health, armor)

func _on_head_hitbox_area_entered(area):
	if not is_multiplayer_authority():
		return
	if area.is_in_group("bullet"):
		print("Bullet hit head!")
		$health_sprite.take_damage(bullet_damage)
		hud.update_hud_health_and_armor(health, armor)

func is_dead():
	return health <= 0
