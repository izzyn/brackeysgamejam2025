extends GPUParticles3D

@onready var timer = $Timer
var rng = RandomNumberGenerator.new()

func _ready():
	emitting = false
	timer.timeout.connect(_on_timer_timeout)
	set_random_timer()
	timer.start()

func _on_timer_timeout():
	restart()
	set_random_timer()
	timer.start()
	
func set_random_timer():
	var random_time = rng.randf_range(15.0,25.0)
	timer.wait_time = random_time
