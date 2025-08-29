extends RayCast3D
class_name WallRay


@onready var player: Player = get_node("..")



func _physics_process(delta: float) -> void:
	if player.move_vector != Vector2.ZERO:
		target_position = Vector3(player.move_vector.x, 0, -player.move_vector.y) * 0.38
	else:
		target_position = target_position.move_toward(Vector3.ZERO, delta*0.8)
	pass
