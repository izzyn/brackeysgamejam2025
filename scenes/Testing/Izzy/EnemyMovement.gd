extends CharacterBody3D
var movement_speed: float = 2.0
var movement_target_position: Vector3

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var player = get_tree().get_nodes_in_group("Player")[0]
var safe_v : Vector3

func _ready() -> void:
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func _physics_process(delta):
	# Do not query when the map has never synchronized and is empty.
	if player.global_position != movement_target_position:
		movement_target_position = player.global_position
		set_movement_target(movement_target_position)
	if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if navigation_agent.is_navigation_finished():
		return

	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position)
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = safe_velocity
	move_and_slide()
