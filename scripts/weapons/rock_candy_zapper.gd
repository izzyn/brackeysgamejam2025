extends WeaponScene

@onready var charged_particles = $VFX/charged_particles
@onready var timer = $Timer
@onready var animation_player = $AnimationPlayer
@onready var lightning = $VFX/lightning
const ELECTRIC_WAVES = preload("res://assets/materials/electric_waves.material")
const ROCK_CANDY = preload("res://assets/materials/rock_candy.tres")
@export var camera: Camera3D

func _process(delta):
	if can_fire:
		ELECTRIC_WAVES.set_shader_parameter("scale",0.1)
		ROCK_CANDY.set_shader_parameter("emission_strength",10.0)
		charged_particles.emitting = true

func _main_use(): 
	if can_fire:
		print("firing")
		animation_player.stop()
		animation_player.play("fire")
		ELECTRIC_WAVES.set_shader_parameter("scale",1.0)
		ROCK_CANDY.set_shader_parameter("emission_strength",2.0)
		charged_particles.emitting = false
		lightning.emitting = true
		can_fire = false
		timer.start(cooldown)
		await timer.timeout
		can_fire = true
		
	
func _secondary_use(): 
	pass

	
