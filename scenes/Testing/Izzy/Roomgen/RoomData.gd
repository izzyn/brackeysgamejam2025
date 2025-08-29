extends Resource
class_name RoomData

enum Direction {UP, DOWN, LEFT, RIGHT}
var coords : Vector2
var walls : Array[Wall]
var directions : Dictionary[Wall, Direction]
var room_name : String = "#"
