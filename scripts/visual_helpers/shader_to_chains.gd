extends Node3D

@export var chain_shader_material: ShaderMaterial

func _ready():
	apply_shader_to_chain_meshes()

func apply_shader_to_chain_meshes():
	var chain_meshes = []
	find_chain_meshes(get_tree().root, chain_meshes)
	
	for mesh_instance in chain_meshes:
		if chain_shader_material:
			# Create a unique instance of the material for each mesh
			var unique_material = chain_shader_material.duplicate()
			mesh_instance.material_override = unique_material
		else:
			push_warning("No ShaderMaterial assigned in the inspector!")

func find_chain_meshes(node: Node, found_meshes: Array):
	if node.name == "Chain_013" and node is MeshInstance3D:
		found_meshes.append(node)
	
	for child in node.get_children():
		find_chain_meshes(child, found_meshes)
