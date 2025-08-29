extends Node

var selected : int
var weapons : Array[Weapon]

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("primary_action"):
		get_node("../Camera/WeaponSlot/Weapon")._main_use()
	pass
