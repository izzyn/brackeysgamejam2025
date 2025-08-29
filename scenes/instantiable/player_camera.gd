extends Camera3D
class_name PlayerCamera

@onready var player: Player = get_node("..")

@export var velocity_tilt_strength: float = 6.6
@export var velocity_sink_strength: float = 4.5

@export var velocity_tilt_speed: float = 45.0
@export var velocity_sink_speed: float = 2.50

@onready var camer_Start_pos: Vector3 = position

func _process(delta: float) -> void:
	var aligned_vel: Vector2 = Vector2(player.velocity.x, player.velocity.z).rotated(player.rotation.y)
	var target_rot: float = -aligned_vel.x*velocity_tilt_strength*0.01
	var target_pos: float = 0
	if(player.is_on_floor()):
		target_pos = -abs(aligned_vel.y)*velocity_sink_strength*0.001
	rotation_degrees.z = move_toward(rotation_degrees.z, target_rot, delta*velocity_tilt_speed)
	position.y = move_toward(position.y, target_pos + camer_Start_pos.y, delta*velocity_sink_speed)
	position.z = move_toward(position.z, (target_pos + camer_Start_pos.z), delta*velocity_sink_speed)
	pass
