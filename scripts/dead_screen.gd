extends CanvasLayer

var countdown_time: int = 3
var countdown_text

func _ready():
	countdown_text = $ColorRect/respawn_counter_text
	$Timer.start()

func _on_timer_timeout():
	if countdown_time == 0:
		$Timer.stop()
	countdown_time -= 1
	countdown_text.text = str(countdown_time)
