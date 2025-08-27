extends CharacterBody3D
class_name Player

@onready
var camera: Camera3D = get_node("Camera")

@onready var wallRay: WallRay = get_node("WallRay")

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pass
	

func _input(event: InputEvent) -> void:
	
	
	#Handle mosue input and reset incase 
	if(event is InputEventMouseMotion):
		var mouse_event: InputEventMouseMotion = event as InputEventMouseMotion
		mouse_delta = -mouse_event.relative
	
	if(event.is_action_type()):
		if(event.is_action_pressed("move_jump")):
			jumping = true
		if(event.is_action_released("move_jump")):
			jumping = false
			sprinting = event.is_action_pressed("move_sprint")
		
	
	pass

func reset_input():
	mouse_delta = Vector2.ZERO
	pass

func handle_input():
	move_vector = Input.get_vector("move_left","move_right","move_backwards","move_forward").normalized()
	pass



## Input Globals
var mouse_delta: Vector2

var move_vector: Vector2

var jumping: bool

var sprinting: bool

@export
var m_sensitivity: Vector2 = Vector2(0.25, 0.25)

@export
var floor_drag: float = 0.5

@export
var wall_fall_speed: float = -2.0

@export
var air_drag: float = 0.5

@export
var movement_speed: float = 10
@export
var sprint_speed: float = 10

@export
var air_speed_control: float = 0.2

@export
var air_clamp: float = 0.25;

@export
var jump_force: float =  100


@export
var gravity_accel: float =  -9.28

## Player globals, for use between frames
var acceleration: Vector3

func _process(delta: float) -> void:
	handle_input()

	## Handle mouse motion and turn into fps camera controls
	camera.rotation_degrees += Vector3(mouse_delta.y*m_sensitivity.y*delta, 0, 0)
	rotation_degrees += Vector3(0, mouse_delta.x*m_sensitivity.x*delta, 0)
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)
	
		## Reset mosue delta each frame so input isn't repeated each frame
	reset_input()
func _physics_process(delta: float) -> void:
	air_speed_control = clamp(3.0 - velocity.length()/movement_speed, 0, 3.0)
	var aligned_move_vector: Vector3
	aligned_move_vector += -move_vector.y*global_basis.z
	aligned_move_vector += move_vector.x*global_basis.x
	
	
	var wall_jump
	if(is_on_floor()):
		var new_velocityVector: Vector3 = aligned_move_vector*movement_speed
		velocity.x = new_velocityVector.x
		velocity.z = new_velocityVector.z
	else:
		var new_velocityVector: Vector3 = aligned_move_vector*movement_speed
		var velocity_clamp: Vector3 = clamp(movement_speed*Vector3.ONE - velocity.abs().clampf(0, movement_speed), Vector3.ZERO, Vector3.ONE)
		
		velocity_clamp *=  Vector3.ONE.normalized()*movement_speed - Vector3(velocity.x, 1.0/air_clamp, velocity.z)*air_clamp
		velocity.x += clampf(new_velocityVector.x*delta*air_speed_control, -velocity_clamp.x, velocity_clamp.x)
		velocity.z += clampf(new_velocityVector.z*delta*air_speed_control, -velocity_clamp.z, velocity_clamp.z)
	
	
	if(!is_on_floor()):
		if(velocity.y < 0):
			if(wallRay.is_colliding()):
				velocity = Vector3.ZERO
				velocity = Vector3(0, wall_fall_speed, 0)
				
				if(jumping):
					velocity = wallRay.get_collision_normal()*jump_force
					velocity.y = jump_force
					
				
			else:
				velocity.y += gravity_accel*delta
		else:
			velocity.y += gravity_accel*delta
	else:
		velocity.y = 0
	if(jumping and is_on_floor()):
		velocity.y = jump_force
		#jumping = false
		
	move_and_slide()

	
	
	pass
