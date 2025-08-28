extends Control

var cells : Array[Array]
var room_nr : int = 12
var grid_size : int = 8
var roomgen_complete : bool

@export
var rooms : Array[PackedScene]

func _ready() -> void:
	roomgen()
	generate_rooms()
	pass

func generate_rooms():
	var displacement_vector : Vector3 = Vector3.ZERO
	var last_x = 0
	for y in cells: 
		for cell : RoomData in y: 
			if cell.room_name == "#":
				continue
			
			var picked_room = rooms.pick_random().instantiate()
			var roomsnode = get_node("../Rooms")
			
			roomsnode.add_child(picked_room)
			picked_room.position = displacement_vector
			cell.room_scene = picked_room
			last_x += 400
			displacement_vector.x += 400
		if last_x != 0:
			displacement_vector.z += 400
	
	for y in cells: 
		for cell : RoomData in y: 
			if cell.room_name == "#" or !cell.room_scene:
				continue
			
			for gate in cell.room_scene.get_node("base_room/doors").get_children():
				var dir = 0
				var other_gate = ""
				if gate.name == "north_gate":
					dir = RoomData.Direction.UP
					other_gate = "south_gate"
				elif gate.name == "south_gate":
					dir = RoomData.Direction.DOWN
					other_gate = "north_gate"
				elif gate.name == "east_gate":
					dir = RoomData.Direction.RIGHT
					other_gate = "west_gate"
				elif gate.name == "west_gate":
					dir = RoomData.Direction.LEFT
					other_gate = "east_gate"
				
				if dir not in cell.directions:
					gate.get_node("AnimationPlayer").play("gate_close")
					gate.get_node("Portal/Screen").get_active_material(0).set_shader_parameter("active", 0.0) 
					continue
				var walldata = cell.directions[dir]
				
				if !walldata.open:
					gate.get_node("AnimationPlayer").play("gate_close")
					gate.get_node("Portal/Screen").get_active_material(0).set_shader_parameter("active", 0.0) 
					continue
				for item : RoomData in walldata.separated_cells:
					if item != cell:
						var portaltolink =item.room_scene.get_node("base_room/doors/%s/Portal" % other_gate)
						gate.get_node("Portal").linked = true
						gate.get_node("Portal").linked_portal = portaltolink

	pass
func roomgen():
	var rooms_made = 1
	var walls : Array
	cells.clear()
	for y in range(grid_size):
		cells.append([])
		for x in range(grid_size):
			var cell = RoomData.new()
			cell.coords = Vector2(x,y)
			if x != 0:
				walls.append(genwall(cell, cells[y][x-1], false))
			if y != 0:
				walls.append(genwall(cell, cells[y-1][x], true))
			cells[y].append(cell)
	
	var startcellidx = floor(grid_size/2)
	var walls_to_visit = []
	var visited_walls = []
	var startcel = cells[startcellidx][startcellidx]
	startcel.room_name = "s"
	walls_to_visit.append_array(startcel.walls)
	var random = RandomNumberGenerator.new()
	random.randomize()

	while len(walls_to_visit) != 0:
		if rooms_made == room_nr:
			break
		var statusstr = ""
		for y in range(grid_size):
			statusstr += "\n"
			for x in range(grid_size):
				statusstr += "%s, " % cells[y][x].room_name
		print(statusstr)
		var selectedwallidx = random.randi() % len(walls_to_visit)
		var selectedwall = walls_to_visit[selectedwallidx]
		walls_to_visit.erase(selectedwall)
		visited_walls.append(selectedwall)
		#XOR
		if (selectedwall.separated_cells[0].room_name == "#") != (selectedwall.separated_cells[1].room_name == "#"):
			selectedwall.open = true
			for cell in selectedwall.separated_cells:
				if cell.room_name == "#":
					cell.room_name = "0"
					rooms_made += 1
					for wall in cell.walls:
						if wall not in visited_walls:
							walls_to_visit.append(wall)
	
	var statusstr = ""
	for y in range(grid_size):
		statusstr += "\n"
		for x in range(grid_size):
			statusstr += "%s, " % cells[y][x].room_name
	print(statusstr)
	pass

func genwall(cell1, cell2, vertical) -> Wall:
	var nwall = Wall.new()
	cell1.walls.append(nwall)
	nwall.separated_cells.append(cell1)
	cell2.walls.append(nwall)
	nwall.separated_cells.append(cell2)
	if vertical:
		cell1.directions[RoomData.Direction.DOWN]=nwall
		cell2.directions[RoomData.Direction.UP]=nwall
	else:
		cell1.directions[RoomData.Direction.LEFT]=nwall
		cell2.directions[RoomData.Direction.RIGHT]=nwall
	return nwall
	pass
