extends CanvasLayer

var health_int: int
var ammo_int: int
# Called when the node enters the scene tree for the first time.
func _ready():
	health_int = int($health_number.text)
	ammo_int = int($ammo_number.text)
	
func _process(_delta):
	pass

func update_hud_health_and_armor(health: float, armor: float):
	$health_number.text = str(int(round(health)))
	$armor_number.text = str(int(round(armor)))

func reset():
	$health_number.text = "100"
	$armor_number.text = "100"
	_ready()

func decrease_hud_ammo():
	if ammo_int > 0:
		ammo_int -= 1
		$ammo_number.text = str(ammo_int)

func _on_tick_timeout():
	if ammo_int < 5:
		ammo_int += 1
		$ammo_number.text = str(ammo_int)
	
	if health_int > 100:
		health_int -= 1
		$health_number.text = str(health_int)
