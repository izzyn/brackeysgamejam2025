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
	
	if( event.is_action_type()):
		if(event.is_action_pressed("move_jump")):
			jumped = true;
	
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

var jumped: bool

@export
var m_sensitivity: Vector2 = Vector2(16.0, 16.0)

@export
var floor_drag: float = 0.5

@export
var wall_fall_speed: float = -0.8
@export
var wall_jump_hirosontal_multiplier: float = 1.2
@export
var wall_jump_vertical_multiplier: float = 1.1

@export
var max_cons_wall_jumps: int = 4

@export
var movement_speed: float = 11.0


@export
var air_speed_clamp: float = 0.4

@export
var air_clamp: float = 1.1;

@export
var jump_velocity: float =  6.0


@export
var gravity_accel: float =  -14.0

## Player globals, for use between frames

var wall_jumps_done: int = 0

var is_wall_sliding: bool

func _process(delta: float) -> void:
	handle_input()

	## Handle mouse motion and turn into fps camera controls
	camera.rotation_degrees += Vector3(mouse_delta.y*m_sensitivity.y*delta, 0, 0)
	rotation_degrees += Vector3(0, mouse_delta.x*m_sensitivity.x*delta, 0)
	
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)
	
		## Reset mosue delta each frame so input isn't repeated each frame
	reset_input()
func _physics_process(delta: float) -> void:
	air_speed_clamp = clamp(3.0 - velocity.length()/movement_speed, 0, 3.0)
	var aligned_move_vector: Vector3
	aligned_move_vector += -move_vector.y*global_basis.z
	aligned_move_vector += move_vector.x*global_basis.x
	
	
	var wall_jump
	if(is_on_floor()):
		var new_velocityVector: Vector3 = aligned_move_vector*movement_speed
		velocity.x = new_velocityVector.x
		velocity.z = new_velocityVector.z
		
		wall_jumps_done = 0
	else:
		var new_velocityVector: Vector3 = aligned_move_vector*movement_speed
		var velocity_clamp: float = movement_speed*air_clamp

		var old_y: float = velocity.y
		
		velocity = clampvm(velocity+new_velocityVector*delta*air_speed_clamp, 0, velocity_clamp)
		
		velocity.y = old_y
	
	if(!is_on_floor()):
		if(velocity.y < 0):
			if(wallRay.is_colliding() and absf(wallRay.get_collision_normal().y) <= 0.00005):  
				velocity = Vector3.ZERO
				velocity = Vector3(0, wall_fall_speed, 0)
				is_wall_sliding = true
				if(Input.is_action_just_pressed("move_jump") and wall_jumps_done < max_cons_wall_jumps):
					velocity = wallRay.get_collision_normal()*jump_velocity*wall_jump_hirosontal_multiplier
					velocity.y = jump_velocity*1.5*wall_jump_vertical_multiplier
					wall_jumps_done += 1
				
			else:
				is_wall_sliding = false
				velocity.y += gravity_accel*delta
		else:
			is_wall_sliding = false
			velocity.y += gravity_accel*delta
	else:
		is_wall_sliding = false
		velocity.y = 0
	if(Input.is_action_just_pressed("move_jump") and is_on_floor()):
		velocity.y = jump_velocity
	move_and_slide()
	jumped = false
	pass

## Clamp vector by/on it's magnitude
func clampvm(vec: Vector3, min: float, max: float)->Vector3:
	var vec_length: float = vec.length()
	
	if(vec_length >= max):
		return vec.normalized()*max
		
	if(vec_length <= min):
		return vec.normalized()*min
	return vec
