extends BasicBullet

@export var vfx_scene: PackedScene
@export var gravity: float = 9.8
var bullet_velocity: Vector3 = Vector3.ZERO

func set_bullet_velocity(new_velocity: Vector3):
	velocity = new_velocity

func _physics_process(delta: float) -> void:
	duration -= delta
	
	if duration < 0:
		queue_free()
		return

	velocity.y -= gravity * delta
	
	var col = move_and_collide(velocity * delta)
	
	if col:
		var collider = col.get_collider()

		if collider and collider.is_in_group("player"):
			return

		if vfx_scene:
			var vfx = vfx_scene.instantiate()
			get_tree().root.add_child(vfx)
			vfx.global_position = col.get_position()
		
		queue_free()
