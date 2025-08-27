extends CharacterBody3D


@onready
var camera: Camera3D = get_node("Camera")

@onready var wallRays: WallRays = get_node("WallRays")

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pass
	

func _input(event: InputEvent) -> void:
	
	
	#Handle mosue input and reset incase 
	if(event is InputEventMouseMotion):
		var mouse_event: InputEventMouseMotion = event as InputEventMouseMotion
		mouse_delta = -mouse_event.relative
	

	pass

func reset_input():
	mouse_delta = Vector2.ZERO
	pass

func handle_input():
	move_vector = Input.get_vector("move_left","move_right","move_backwards","move_forward").normalized()
	
	jumped = Input.is_action_just_pressed("move_jump")
	
	sprinting = Input.is_action_pressed("move_sprint")
	
	pass



## Input Globals
var mouse_delta: Vector2

var move_vector: Vector2

var jumped: bool

var sprinting: bool

@export
var m_sensitivity: Vector2 = Vector2(0.25, 0.25)

@export
var floor_drag: float = 0.5
@export
var air_drag: float = 0.5

@export
var movement_speed: float = 10
@export
var sprint_speed: float = 10

@export
var air_speed_control: float = 0.2

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
	
	var aligned_move_vector: Vector3
	aligned_move_vector += -move_vector.y*global_basis.z
	aligned_move_vector += move_vector.x*global_basis.x
	
	if(is_on_floor() and sprinting):
		acceleration = aligned_move_vector*sprint_speed
	elif(is_on_floor()):
		acceleration = aligned_move_vector*movement_speed
	else:
		acceleration = aligned_move_vector*movement_speed*air_speed_control
	
	if (!is_on_floor()):
		acceleration.y += gravity_accel
		#print("Applying gravity")
	elif(!wallRays.isAnyHitting()):
		acceleration.y += gravity_accel*0.01
		
	if(is_on_floor() and jumped):
		acceleration.y += jump_force/delta
	
	velocity += acceleration*delta
	
	if(is_on_floor()):
		velocity -= velocity*delta*floor_drag*Vector3(1,0,1)
	else:
		velocity -= velocity*delta*air_drag*Vector3(1,0,1)

	move_and_slide()

	
	
	pass
