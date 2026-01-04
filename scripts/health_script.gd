extends Sprite3D

func _ready():
	if is_multiplayer_authority():
		visible = false

	$SubViewport/health_bar.max_value = 100
	$SubViewport/health_bar.value = 100

func take_damage(damage: float):
	$SubViewport/health_bar.value -= damage
