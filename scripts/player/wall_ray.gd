extends RayCast3D
class_name WallRay


@onready var player: Player = get_node("..")



func _physics_process(delta: float) -> void:
	target_position = Vector3(player.move_vector.x, 0, -player.move_vector.y) * 0.5
	pass
