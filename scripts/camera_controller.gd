extends Node3D

var player
@export var sensitivity := 5

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_nodes_in_group("Player")[0]
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	global_position = player.global_position
	pass

# handles camera look angle relative to mouse movement
# mouse input x and y values are divided by 1000 to create 1:1 translation from 2D to 3D
# clamp function limits up and down camera look angle,
# 2nd argument = upper bounds, 3rd argumment = lower bounds
func _input(event):
	if not is_multiplayer_authority():
		return
	if event is InputEventMouseMotion:
		var temp_rotation = rotation.z - event.relative.y / 1000 * sensitivity
		temp_rotation = clamp(temp_rotation, -0.5, 0.5)
		
		rotation.z = temp_rotation
		rotation.y -= event.relative.x / 1000 * sensitivity
