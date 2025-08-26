extends Control

var cells : Array[Array]
var room_nr : int = 20
var grid_size : int = 8
var roomgen_complete : bool
func _ready() -> void:
	#roomgen()
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
		cell1.directions[nwall]=RoomData.Direction.DOWN
		cell2.directions[nwall]=RoomData.Direction.UP
	else:
		cell1.directions[nwall]=RoomData.Direction.LEFT
		cell2.directions[nwall]=RoomData.Direction.RIGHT
	return nwall
	pass
