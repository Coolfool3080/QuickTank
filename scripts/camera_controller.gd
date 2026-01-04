extends Node3D

@export var target: Node3D
@export var max_pitch := 0.6

@onready var pitch_node = $camera_pitch

const MAX_Y_ROTATION = 0.6
const CAMERA_SENSITIVITY = 0.001

var yaw = 0.0
var pitch = 0.0
var camera_rotation: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not target:
		return
	
	global_position = target.global_position
	global_rotation.y = yaw
	pitch_node.rotation.x = pitch

func _input(event):
	if not is_multiplayer_authority():
		return
		
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * CAMERA_SENSITIVITY
		pitch -= event.relative.y * CAMERA_SENSITIVITY
		pitch = clamp(pitch, -max_pitch, max_pitch)
