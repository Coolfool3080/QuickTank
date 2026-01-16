extends CharacterBody3D

@export var SPEED = 5

var damage = 10
var has_bounced = false
var shooter

func _ready():
	velocity = -transform.basis.z * SPEED
	

func _process(delta):
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		if collision.get_collider().is_in_group("hit_object") and !has_bounced:
			velocity = velocity.bounce(collision.get_normal())
			has_bounced = true
		else:
			queue_free()

func _on_hit_box_area_entered(area):
	if area.is_in_group("hit_player"):
		queue_free()

func _on_bullet_despawn_timer_timeout():
	queue_free()
