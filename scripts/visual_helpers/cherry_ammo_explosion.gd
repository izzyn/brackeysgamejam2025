extends Node3D

@onready var explosion_light = $ExplosionLight
@onready var timer = $Timer

func _ready():
	explosion_light.explosion()
	await timer.timeout
	queue_free()
