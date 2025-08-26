extends Node

var camera_controls_enabled: bool = true

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_camera_controls()
	
	if event.is_action_pressed("reset_scene"):
		get_tree().reload_current_scene()

func toggle_camera_controls():
	camera_controls_enabled = !camera_controls_enabled
	
	if camera_controls_enabled:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func is_camera_control_enabled() -> bool:
	return camera_controls_enabled
