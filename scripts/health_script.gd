extends Sprite3D

# Called when the node enters the scene tree for the first time.
func _ready():
	$SubViewport/health_bar.max_value = 5
	$SubViewport/health_bar.value = 5

func take_damage(damage: float):
	$SubViewport/health_bar.value -= damage
