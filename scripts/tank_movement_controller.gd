extends CharacterBody3D

@onready var camera_pivot = $camera_pivot
@onready var head_node = $head
@onready var fast_head = $head2
@onready var head_barrel = $head/head_mesh/barrel_pivot
@onready var fast_barrel = $head2/barrel_pivot2
@onready var fire_cooldown_timer = $fire_cooldown_timer

@export var Bullet: PackedScene

const MOVE_SPEED = 5.0
const ROTATION_SPEED = 1.5
const CAMERA_SENSITIVITY = 0.001
const HEAD_ROTATE_SPEED = 2.0

var tank_health = 5
var kill_count = 0
var camera_yaw = 0.0
var camera_pitch = 0.0
var hud

func _enter_tree() -> void:
	set_multiplayer_authority(int(name))
	
func _ready():
	if is_multiplayer_authority():
		$camera_pivot/Camera3D.current = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		hud = preload("res://assets/tank_hud.tscn").instantiate()
		get_tree().get_root().add_child(hud)
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
		velocity.x = move_toward(velocity.x, 0, MOVE_SPEED * 4 * delta)
		velocity.z = move_toward(velocity.z, 0, MOVE_SPEED * 4 * delta)
	
	move_and_slide()
	
	var camera_global_yaw = camera_pivot.global_transform.basis.get_euler().y
	var tank_yaw = global_transform.basis.get_euler().y
	var relative_yaw = camera_global_yaw - tank_yaw
	
	var camera_global_pitch = camera_pivot.global_transform.basis.get_euler().x
	var tank_pitch = global_transform.basis.get_euler().x
	var relative_pitch = camera_global_pitch - tank_pitch
	
	head_node.rotation.y = lerp_angle(head_node.rotation.y, relative_yaw, delta * HEAD_ROTATE_SPEED)
	head_barrel.rotation.x = lerp_angle(head_barrel.rotation.x, relative_pitch, delta * HEAD_ROTATE_SPEED)
	
	
	fast_head.rotation.y = relative_yaw
	fast_barrel.rotation.x = relative_pitch

	var barrel = $head/head_mesh/barrel_pivot
	var camera = get_viewport().get_camera_3d()
	var aim_origin = barrel.global_transform.origin
	var aim_direction = -barrel.global_transform.basis.z
	var target_point = aim_origin + aim_direction * 1000

	var query = PhysicsRayQueryParameters3D.new()
	query.from = aim_origin
	query.to = target_point
	query.collision_mask = 1

	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)

	var crosshair_pos = Vector2.ZERO
	
	var hud_center = hud.get_node("Line2D")
	var hud_crosshair = hud.get_node("crosshair")

	if result:
		crosshair_pos = camera.unproject_position(result.position)
	else:
		crosshair_pos = camera.unproject_position(target_point)

	if camera.is_position_behind(target_point):
		hud_center.visible = false
	else:
		hud_center.visible = true
		hud_center.position = crosshair_pos
	
	var barrel2 = $head2/barrel_pivot2
	var camera2 = get_viewport().get_camera_3d()
	var aim_origin2 = barrel2.global_transform.origin
	var aim_direction2 = -barrel2.global_transform.basis.z
	var target_point2 = aim_origin2 + aim_direction2 * 1000
	
	var query2 = PhysicsRayQueryParameters3D.new()
	query2.from = aim_origin2
	query2.to = target_point2
	query2.collision_mask = 1
	
	var space_state2 = get_world_3d().direct_space_state
	var result2 = space_state2.intersect_ray(query2)
	var crosshair_pos2 = Vector2.ZERO
	
	if result2:
		crosshair_pos2 = camera2.unproject_position(result2.position)
	else:
		crosshair_pos2 = camera2.unproject_position(target_point2)

	if camera2.is_position_behind(target_point2):
		hud_crosshair.visible = false
	else:
		hud_crosshair.visible = true
		hud_crosshair.position = crosshair_pos2
	
	#shoot
func _input(event):
	if not is_multiplayer_authority():
		return
		
	if event.is_action_pressed("shoot") and fire_cooldown_timer.is_stopped():
		shoot.rpc()

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
		$health_sprite.take_damage(1)
		tank_health -= 1

func _on_head_hitbox_area_entered(area):
	if not is_multiplayer_authority():
		return
	if area.is_in_group("bullet"):
		print("Bullet hit head!")
		$health_sprite.take_damage(1)
		tank_health -= 1

func is_dead():
	return tank_health < 1
