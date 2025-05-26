extends Marker3D

var target_pos: Vector3 = Vector3()

const turn_speed = 5
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var target_pos: Vector3 = get_parent().get_node("camera_controller/look_node").global_position
	var head_position: Vector3 = global_position
	#var transformed = target.get_global_transform_interpolated()
	
	#target_pos = lerp(transformed.origin, target_pos, delta / 1)
	
	#look_at(target_pos, Vector3(0,1,0))
	var look_vector = Vector3(target_pos.x, target_pos.y,target_pos.z)
	var translated = rotate_object_local(Vector3(1,0,0), 0.1)
	
	#var look_pos_2d = Vector2(look_position.x, look_position.z)
	
	#var direction = -(look_pos_2d - head_pos_2d)
	#
	#rotation.y = lerp_angle(rotation.y, atan2(direction.x, direction.y), delta / 1)
