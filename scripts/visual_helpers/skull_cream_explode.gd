extends Node3D

@export var impulse_strength: float = 15.0
@export var lifetime: float = 2.0
@onready var explosion_particles = $ExplosionLight


func _ready():
	print("baboom")
	apply_explosion_forces()
	explosion_particles.explosion()
	
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = lifetime
	timer.timeout.connect(queue_free)
	timer.start()

func apply_explosion_forces():
	var rigid_bodies = ["cone", "skull1", "skull2"]
	
	for body_name in rigid_bodies:
		var body = get_node_or_null(NodePath(body_name))
		if body and body is RigidBody3D:
			var direction = Vector3(
				randf_range(-1, 1),
				randf_range(0.5, 1),
				randf_range(-1, 1)
			).normalized()
			
			body.apply_central_impulse(direction * impulse_strength)
			
			var torque = Vector3(
				randf_range(-1, 1),
				randf_range(-1, 1),
				randf_range(-1, 1)
			) * impulse_strength * 0.5
			body.apply_torque_impulse(torque)
