extends Node3D

@onready var animation_player = $AnimationPlayer
@onready var torch_animation_player = $sconce/TorchAnimationPlayer
@onready var gate_collision = $StaticBody3D/GateCollision
@onready var collision_animation_player = $StaticBody3D/CollisionAnimationPlayer

var is_open: bool = false

func open_gate():
	if is_open:
		return
	is_open = true
	
	animation_player.play("gate_open")
	torch_animation_player.play("ignite")
	collision_animation_player.play("collision_open")
	await torch_animation_player.animation_finished
	torch_animation_player.play("on")

func close_gate():
	if not is_open:
		return
	
	is_open = false
	animation_player.play("gate_close")
	torch_animation_player.play("off")
	collision_animation_player.play("collision_close")

func toggle_gate():
	if is_open:
		close_gate()
	else:
		open_gate()
		
