extends WeaponScene

@onready var timer = $Timer
@onready var animation_player = $AnimationPlayer
@export var bullet: PackedScene
@export var camera: Camera3D
@export var arc_height: float = 5.0 
@export var gravity: float = 9.8 
@onready var sparks = $ElectricSparks_1

var bullet_instance

func _main_use(): 
	if can_fire and bullet:
		print("firing grenade")
		animation_player.stop()
		animation_player.play("fire")
		sparks.emitting = false
		
		bullet_instance = bullet.instantiate()
		get_tree().root.add_child(bullet_instance)

		bullet_instance.global_position = self.global_position

		var forward = -camera.global_transform.basis.z
		var up = Vector3.UP
		var launch_direction = forward + up * (arc_height / 10.0)

		if bullet_instance.has_method("set_velocity"):
			bullet_instance.set_velocity(launch_direction * bullet_instance.speed)
		elif bullet_instance is RigidBody3D:
			bullet_instance.linear_velocity = launch_direction * bullet_instance.speed
		elif bullet_instance is CharacterBody3D:
			bullet_instance.velocity = launch_direction * bullet_instance.speed

		bullet_instance.global_rotation = camera.global_rotation

		can_fire = false
		timer.start(cooldown)
		await timer.timeout
		sparks.emitting = true
		can_fire = true

func _secondary_use(): 
	pass
