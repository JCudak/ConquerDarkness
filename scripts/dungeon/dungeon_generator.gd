class_name DungeonGenerator extends Node

enum Tiles {EMPTY, SOLID}

@export var steps: int = 200
@export var border_size: int = 2
var PlayerScene = preload("res://assets/scenes/player/player.tscn")

const MIN_HEIGHT: int = 4
const MIN_WIDTH: int = 2
const WALL_LAYER: int = 1
const GROUND_LAYER: int = 0
const MIDDLE_WALL: int = 2
const TOP_WALL: int = 1
const VOID: int = 0

func _ready():
	pass

func generate(visibility_tile_map: TileMap, tile_map: TileMap, width:int, height:int):
	
	var borders = Rect2(border_size, border_size, width + border_size, height + border_size)
	var walker = Walker.new(Vector2((border_size+width)/2, (border_size+height)/2), borders)
	var map = walker.walk(steps)
	
	var tmp_location: Vector2
	for location in map:
		tmp_location = location
		for i in range(2):
			tmp_location.x = 2*location.x+i
			for j in range(2):
				tmp_location.y=2*location.y+j
				tile_map.set_cell(GROUND_LAYER, tmp_location, 0, Vector2i(0, 0))
				tile_map.set_cell(WALL_LAYER, tmp_location, 1, Vector2i(-1,-1))
				visibility_tile_map.set_cell(GROUND_LAYER, tmp_location, 0, Vector2i(0, 0))
				visibility_tile_map.set_cell(WALL_LAYER, tmp_location, 1, Vector2i(-1,-1))
	ensure_minimum_wall_group_size(tile_map, true)
	connect_atlas_tiles(tile_map)
	ensure_minimum_wall_group_size(visibility_tile_map, true)
	connect_atlas_tiles(visibility_tile_map)
	
	return walker

func connect_atlas_tiles(tile_map: TileMap):
	var used_cells = tile_map.get_used_cells(GROUND_LAYER)
	var used_cells_wall = tile_map.get_used_cells(WALL_LAYER)
	tile_map.set_cells_terrain_connect(GROUND_LAYER, used_cells, GROUND_LAYER, 0)
	
	var meets_condition_1 = func(cell):
		var below_cell_1 = Vector2i(cell.x, cell.y + 1)
		var below_cell_2 = Vector2i(cell.x, cell.y + 2)
		return used_cells.has(below_cell_1) or (used_cells_wall.has(below_cell_1) and used_cells_wall.has(below_cell_2))
	var meets_condition_2 = func(cell):
		var below_cell_1 = Vector2i(cell.x, cell.y + 1)
		var below_cell_2 = Vector2i(cell.x, cell.y + 2)
		var below_cell_3 = Vector2i(cell.x, cell.y + 3)
		return (used_cells_wall.has(below_cell_1) and used_cells.has(below_cell_2)) or (used_cells_wall.has(below_cell_1) and used_cells_wall.has(below_cell_1) and used_cells.has(below_cell_3))
	var meets_condition_3 = func (cell):
		var below_cell_1 = Vector2i(cell.x, cell.y + 1)
		var below_cell_2 = Vector2i(cell.x, cell.y + 2)
		return !used_cells.has(below_cell_1) and !used_cells.has(below_cell_2)
	
	# Apply terrain connection for each condition
	var used_cells_with_walls_1 = used_cells_wall.filter(meets_condition_1)
	tile_map.set_cells_terrain_connect(WALL_LAYER, used_cells_with_walls_1, WALL_LAYER, MIDDLE_WALL)
	
	var used_cells_with_walls_2 = used_cells_wall.filter(meets_condition_2)
	tile_map.set_cells_terrain_connect(WALL_LAYER, used_cells_with_walls_2, WALL_LAYER, TOP_WALL)
	
	var used_cells_with_walls_3 = used_cells_wall.filter(meets_condition_3)
	tile_map.set_cells_terrain_connect(WALL_LAYER, used_cells_with_walls_3, WALL_LAYER, VOID)


func ensure_minimum_wall_group_size(tile_map: TileMap, try_to_draw: bool = false):
	var used_cells_wall
	if try_to_draw:
		for i in range(3):
			used_cells_wall = tile_map.get_used_cells(GROUND_LAYER)
			for cell in used_cells_wall:
				if is_floor_tile_with_wall_below(tile_map, cell):
					set_wall(tile_map, cell)
	else:
		for i in range(4):
			used_cells_wall = tile_map.get_used_cells(WALL_LAYER)
			for cell in used_cells_wall:
					if is_part_of_wall_of_height_3_or_less(tile_map, cell):
						set_floor(tile_map, cell)


func is_floor_tile_with_wall_below(tile_map: TileMap, floor_cell: Vector2i) -> bool:
	var start_cell = floor_cell + Vector2i(0, 1)
	var wall_length = 0
	
	for offset in range(5):
		var check_cell = start_cell + Vector2i(0, offset)
		
		if tile_map.get_cell_atlas_coords(WALL_LAYER, check_cell) != Vector2i(-1, -1):
			wall_length += 1
		else:
			break
			
	return wall_length >= 1 and wall_length < 4

func is_part_of_wall_of_height_3_or_less(tile_map: TileMap, cell: Vector2i) -> bool:
	var max_wall_height: int = 3
	var wall_length_up: int = 0
	var wall_length_down: int = 0
	
	for offset in range(max_wall_height + 1):
		var check_cell_down = cell + Vector2i(0, offset)
		if tile_map.get_cell_atlas_coords(WALL_LAYER, check_cell_down) != Vector2i(-1, -1):
			wall_length_down += 1
		else:
			break
	
	for offset in range(max_wall_height + 1):
		var check_cell_up = cell - Vector2i(0, offset)
		if tile_map.get_cell_atlas_coords(WALL_LAYER, check_cell_up) != Vector2i(-1, -1):
			wall_length_up += 1
		else:
			break
	var total_wall_length = wall_length_up + wall_length_down - 1
	return total_wall_length >= 1 and total_wall_length <= max_wall_height


func set_wall(tile_map: TileMap, cell):
	tile_map.set_cell(WALL_LAYER, cell, 1, Vector2i(0,3))
	tile_map.set_cell(GROUND_LAYER, cell, 0, Vector2i(-1,-1))

func set_floor(tile_map: TileMap, cell):
	tile_map.set_cell(WALL_LAYER, cell, 1, Vector2i(-1,-1))
	tile_map.set_cell(GROUND_LAYER, cell, 0, Vector2i(0,0))
