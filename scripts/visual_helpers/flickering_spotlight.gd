extends SpotLight3D

@export var noise: NoiseTexture3D
@export var flicker_speed: float = 2.0
@export var position_jitter_amount: float = 0.1
var time_passed := 0.0
var time_offset := 0.0
var original_position: Vector3

func _ready():
	time_offset = randf() * 100.0
	original_position = global_position

func _process(delta):
	time_passed += delta * flicker_speed
	
	var sampled_noise = noise.noise.get_noise_1d(time_passed + time_offset)
	sampled_noise = abs(sampled_noise)
	
	# Apply to light energy
	light_energy = sampled_noise
	
	# Apply to position - use different noise samples for each axis
	var noise_x = noise.noise.get_noise_2d(time_passed + time_offset, 0.0)
	var noise_y = noise.noise.get_noise_2d(time_passed + time_offset, 1.0)
	var noise_z = noise.noise.get_noise_2d(time_passed + time_offset, 2.0)
	
	var jitter = Vector3(
		noise_x * position_jitter_amount,
		noise_y * position_jitter_amount,
		noise_z * position_jitter_amount
	)
	
	global_position = original_position + jitter
