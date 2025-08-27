extends Node3D
class_name WallRays
@onready var leftRay: RayCast3D = get_node("WallRayLeft")
@onready var rightRay: RayCast3D = get_node("WallRayRight")



func isAnyHitting()->bool:
	return (leftRay.is_colliding() or rightRay.is_colliding())
