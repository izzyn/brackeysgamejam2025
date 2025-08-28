extends Control

var rectsize = 100
func _ready():
	#var posoffset = rectsize * get_parent().grid_size/2
	#position += Vector2(-posoffset, posoffset)
	get_parent().roomgen()
	pass
func _draw():
	var rooms = get_parent().cells
	
	for y in len(rooms):
		for x in len(rooms[y]):
			if rooms[y][x].room_name != "#":
				for wall in rooms[y][x].walls:
					if wall.open:
						var offset = Vector2(rectsize,rectsize)/2
						var color = Color.RED
						#var direction = rooms[y][x].directions[wall]
						#if direction == RoomData.Direction.UP or direction == RoomData.Direction.DOWN:
							#color = Color.BLUE
						draw_line(wall.separated_cells[0].coords * 1.1 * rectsize + offset, wall.separated_cells[1].coords * 1.1 * rectsize + offset, color, 50)
	for y in len(rooms):
		for x in len(rooms[y]):
			if rooms[y][x].room_name != "#":
				draw_rect(Rect2(rooms[y][x].coords * 1.1 * rectsize, Vector2(rectsize,rectsize)),Color.GRAY)
