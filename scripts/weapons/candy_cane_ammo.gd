extends BasicBullet

func _physics_process(delta: float) -> void:
	duration -= delta
	
	if duration < 0:
		queue_free()
		return
