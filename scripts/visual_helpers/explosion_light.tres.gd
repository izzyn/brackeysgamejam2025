@tool
extends Node3D

@onready var fire: GPUParticles3D = $Fire
@onready var sparks: GPUParticles3D = $Sparks
@onready var smoke: GPUParticles3D = $Smoke

func explosion() -> void:
	fire.restart()
	sparks.restart()
	smoke.restart()
	
	
