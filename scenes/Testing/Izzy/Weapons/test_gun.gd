extends WeaponScene

func _main_use(): 
	var bullet = preload("res://scenes/Testing/Izzy/Projectiles/Basic_Bullet.tscn")
	var bullet_instance = bullet.instantiate()
	
	get_node("/root").add_child(bullet_instance)
	bullet_instance.global_position = self.global_position
	bullet_instance.global_rotation = get_node("../../Camera3D").global_rotation
	pass
	
func _secondary_use(): 
	pass
