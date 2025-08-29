extends WeaponScene

@onready var timer = $Timer
@onready var animation_player = $candy_cane_launcher/AnimationPlayer
@export var bullet: PackedScene
@export var camera: Camera3D
var bullet_instance

func _main_use(): 
	if can_fire and bullet:
		print("firing")
		animation_player.stop()
		animation_player.play("fire")
		bullet_instance = bullet.instantiate()
		get_node("/root").add_child(bullet_instance)
		bullet_instance.global_position = self.global_position
		bullet_instance.global_rotation = camera.global_rotation
		can_fire = false
		timer.start(cooldown)
		await timer.timeout
		can_fire = true
		
	
func _secondary_use(): 
	pass

	
