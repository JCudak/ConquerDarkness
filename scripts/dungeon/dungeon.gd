extends Node2D

@export var map_width: int = 30
@export var map_height: int = 15
@onready var dungeon = $Dungeon

var dungeonGenerator: DungeonGenerator = DungeonGenerator.new()

func _ready():
	dungeonGenerator.generate(dungeon, map_width, map_height)

