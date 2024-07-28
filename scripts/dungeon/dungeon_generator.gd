class_name DungeonGenerator extends Node

enum Tiles {EMPTY, SOLID}
enum Layers {GROUND, WALL}

@export var player: Player
@export var steps: int = 200

func _ready():
	randomize()

func generate(tile_map: TileMap, width:int, height:int):
	
	var borders = Rect2(1, 1, width + 1, height + 1)
	var walker = Walker.new(Vector2((1+width)/2, (1+height)/2), borders)
	var map = walker.walk(steps)
	
	walker.queue_free()
	var tmp_location: Vector2
	for location in map:
		tmp_location = location
		for i in range(2):
			tmp_location.x = 2*location.x+i
			for j in range(2):
				tmp_location.y=2*location.y+j
				tile_map.set_cell(Layers.GROUND, tmp_location, 0, Vector2i(0, 0))
				tile_map.set_cell(Layers.WALL, tmp_location, 0, Vector2i(-1,-1))
	connect_atlas_tiles(tile_map)

func connect_atlas_tiles(tile_map: TileMap):
	var used_cells = tile_map.get_used_cells(Layers.GROUND)
	var used_cells_wall = tile_map.get_used_cells(Layers.WALL)
	tile_map.set_cells_terrain_connect(Layers.GROUND, used_cells, Layers.GROUND, 0)
	tile_map.set_cells_terrain_connect(Layers.WALL, used_cells_wall, Layers.WALL, 0)
	#var meets_condition = func(cell):
		#var below_cell = Vector2i(cell.x, cell.y + 2)
		#var above_cell = Vector2i(cell.x, cell.y - 1)
		#return used_cells.has(below_cell) and used_cells_wall.has(above_cell)
	#var used_cells_with_walls = used_cells_wall.filter(meets_condition)
	#tile_map.set_cells_terrain_connect(Layers.WALL, used_cells_with_walls, Layers.WALL, 1)
	#
	#var meets_condition_2 = func(cell):
		#var below_cell = Vector2i(cell.x, cell.y + 1)
		#var above_cell = Vector2i(cell.x, cell.y - 1)
		#return used_cells.has(below_cell) and used_cells_wall.has(above_cell)
	#var used_cells_with_walls_2 = used_cells_wall.filter(meets_condition_2)
	#tile_map.set_cells_terrain_connect(Layers.WALL, used_cells_with_walls_2, Layers.WALL, 2)
	#
	#var meets_condition_3 = func(cell):
		#var below_cell = Vector2i(cell.x, cell.y + 1)
		##var above_cell = Vector2i(cell.x, cell.y - 1)
		#return used_cells.has(below_cell) #and used_cells_wall.has(above_cell)
	#var used_cells_with_walls_3 = used_cells_wall.filter(meets_condition_3)
	#tile_map.set_cells_terrain_connect(Layers.WALL, used_cells_with_walls_3, Layers.WALL, 3)

