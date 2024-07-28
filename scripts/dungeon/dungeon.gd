extends TileMap

@export var map_width: int = 30
@export var map_height: int = 15

var dungeonGenerator: DungeonGenerator = DungeonGenerator.new()

func _ready():
	dungeonGenerator.generate(self, map_width, map_height)

