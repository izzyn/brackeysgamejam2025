extends BasicBullet

@export var stick_rotation_offset := Vector3.ZERO
var is_stuck := false

func _physics_process(delta: float) -> void:
	duration -= delta
	
	if duration < 0:
		queue_free()
		return

	if not is_stuck:
		var col = move_and_collide(-delta * speed * transform.basis.z)
		
		if col:
			var collider = col.get_collider()

			if collider and collider.is_in_group("Player"):
				return  # Ignore player collision

			_stick_to_surface(col)

func _stick_to_surface(col):
	is_stuck = true
	
	# Stop all movement
	velocity = Vector3.ZERO

	var normal = col.get_normal()
	var travel_direction = -transform.basis.z

	if normal != Vector3.ZERO:
		var forward = travel_direction
		
		var right = normal.cross(forward).normalized()
		if right.length() < 0.001:
			right = Vector3.RIGHT.cross(normal).normalized()
			if right.length() < 0.001:
				right = Vector3.UP.cross(normal).normalized()
		
		var up = forward.cross(right).normalized()
		var new_basis = Basis(right, up, forward)
		
		if stick_rotation_offset != Vector3.ZERO:
			new_basis = new_basis.rotated(forward, stick_rotation_offset.y)
			new_basis = new_basis.rotated(right, stick_rotation_offset.x)
			new_basis = new_basis.rotated(up, stick_rotation_offset.z)
		
		transform.basis = new_basis

	global_position = col.get_position()

	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
