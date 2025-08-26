extends CharacterBody3D

@export
var duration : float = 5

@export
var speed : float = 20


func _physics_process(delta: float) -> void:
	duration -= delta
	
	if duration < 0:
		queue_free()
	
	var col = move_and_collide(-delta * speed * transform.basis.z)
	
	if col:
		print(col.get_collider())
		queue_free()
