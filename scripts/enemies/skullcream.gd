extends Node3D

@onready var animation_player = $AnimationPlayer
@onready var explosion_charge = $explosion_charge
@onready var area_3d = $Area3D

@export var explosion_vfx: PackedScene

func _ready():
	animation_player.play("idle")

func _on_area_3d_body_entered(body):
	if body is CharacterBody3D:
		print("boom")
		explode()

func explode():
	animation_player.play("explode")
	explosion_charge.emitting = true
	await animation_player.animation_finished
	var explosion = explosion_vfx.instantiate()
	get_parent().add_child(explosion)
	explosion.global_transform = global_transform
	queue_free()
