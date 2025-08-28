extends Node3D

@export var group_name = "Player"
@export var portal_id : String

@export
var active : bool = true

var linked = false
var linked_portal
var teleported = false

var teleporter_list = []
var teleporter_last_pos_list = []



func _ready():
	#try_to_link()
	pass
	
func _physics_process(delta):
	if linked:
		check_teleport()

func link_portal(portal_to_link):
	if portal_to_link.portal_id == portal_id && !linked && portal_to_link != self:
		linked_portal = portal_to_link
		linked = true
		return true
	else:
		return false
		
func try_to_link():
	for portal in get_tree().get_nodes_in_group("Portals"):
		if portal.link_portal(self):
			break



func check_teleport():
	if teleporter_list.size() != 0:
		var limit = teleporter_list.size()
		for i in limit:
			var teleportee = teleporter_list[i]
			var teleportee_previous_offset_from_portal = teleporter_last_pos_list[i]
			var teleporteeT = teleportee.global_transform
			var offset_from_portal = teleporteeT.origin - global_transform.origin
			var portal_side = sign(offset_from_portal.dot(-global_transform.basis.z))
			var portal_side_old = sign(teleportee_previous_offset_from_portal.dot(-global_transform.basis.z))
			print("aaedpoqwp[oei]")
			if portal_side != portal_side_old:
				print("aaa")
				teleportee.global_transform.origin = linked_portal.global_transform.origin - get_tree().get_nodes_in_group(group_name)[0].camera.transform.origin
				teleporter_list.remove_at(i)
				teleporter_last_pos_list.remove_at(i)
			else:
				teleportee_previous_offset_from_portal = offset_from_portal

func _on_area_3d_body_entered(body):
	print("34rwjpui234wr09i8er234w9-[oei]")
	var teleportee = body
	var teleportee_previous_offset_from_portal = teleportee.global_transform.origin - global_transform.origin
	if teleporter_list.has(body):
		pass
	else:
		teleporter_list.append(body)
		teleporter_last_pos_list.append(teleportee_previous_offset_from_portal)

func _on_area_3d_body_exited(body):
	teleported = false
	teleporter_list.clear()
	teleporter_last_pos_list.clear()
