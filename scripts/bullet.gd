extends RigidBody3D

@export var SPEED = 5

func _ready():
	pass

func _process(delta):
	move_and_collide(-transform.basis.z * SPEED * delta)

func _on_hit_box_body_entered(body):
	if body.is_in_group("hit_object"):
		print("hit")
		queue_free()
