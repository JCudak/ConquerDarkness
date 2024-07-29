extends Node2D

# Grid size parameters
@export var grid_size: Vector2 = Vector2(16, 16) # Adjust according to your tile size
@export var line_color: Color = Color(1, 0, 0, 0.5) # Red color with 50% opacity

func _draw():
	# Get the current viewport's size
	var viewport_size = get_viewport_rect().size
	
	# Draw vertical lines
	for x in range(0, int(viewport_size.x), int(grid_size.x)):
		draw_line(Vector2(x, 0), Vector2(x, viewport_size.y), line_color, 1)

	# Draw horizontal lines
	for y in range(0, int(viewport_size.y), int(grid_size.y)):
		draw_line(Vector2(0, y), Vector2(viewport_size.x, y), line_color, 1)

func _ready():
	#_draw()
	pass
