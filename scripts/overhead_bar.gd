extends Sprite3D

@onready var player = get_parent()

var health_value: float
var armor_value: float

func _ready():
	if is_multiplayer_authority():
		visible = false
	
	health_value = $SubViewport/health_bar.value
	armor_value = $SubViewport/armor_bar.value

func take_damage(damage: float):
	var health_damage = damage * 0.34
	var armor_damage = damage * 0.66
	
	if armor_value >= armor_damage:
		health_value -= health_damage
		armor_value -= armor_damage
	else:
		var overflow = armor_damage - (armor_value * 0.66)
		health_value -= health_damage + overflow
		armor_value = 0
	
	player.health = str(int(round(health_value)))
	player.armor = str(int(round(armor_value)))
	
	$SubViewport/health_bar.value = player.health
	$SubViewport/armor_bar.value = player.armor
	
