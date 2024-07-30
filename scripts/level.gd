extends Node2D


@onready var player = $SubViewportContainer/LightView/Player
@onready var lights = $SubViewportContainer/LightView/Lights
@onready var healthAndShieldGui = $CanvasLayer/HUD/HpAndShieldGui
@onready var visibility_tile_map = $SubViewportContainer/VisibilityViewport/VisibilityTileMap
@onready var tile_map = $SubViewportContainer/LightView/TileMap
@onready var enemies = $SubViewportContainer/LightView/Enemies
@export var map_width: int = 30
@export var map_height: int = 15
const TorchScene = preload("res://assets/scenes/torch.tscn")
const ExitScene = preload("res://assets/scenes/exit.tscn")
const SLIME = preload("res://assets/scenes/enemies/slime.tscn")
var dungeonGenerator: DungeonGenerator = DungeonGenerator.new()

func _ready():
	generate_map()
	player.healthChanged.connect(healthAndShieldGui.updateHealth)
	player.shieldChanged.connect(healthAndShieldGui.updateShield)
	for torch in lights.get_children():
		if torch is Exit:
			torch.torch.enteredLight.connect(player.torch_area_entered)
			torch.torch.exitedLight.connect(player.torch_area_exited)
		else:
			torch.enteredLight.connect(player.torch_area_entered)
			torch.exitedLight.connect(player.torch_area_exited)

func generate_map():
	var walker: Walker = dungeonGenerator.generate(visibility_tile_map, tile_map, map_width, map_height)
	place_player(walker)
	spawn_monsters(walker)
	spawn_lights(walker)
	spawn_exit(walker)
	
	walker.queue_free()

func place_player(walker: Walker):
	player.position = walker.get_player_room_position()*32

func spawn_lights(walker: Walker):
	for room in walker.rooms:
		if randf_range(0,1)<0.05:
			var torch = TorchScene.instantiate()
			torch.position = room.position*32
			lights.add_child(torch)

func spawn_monsters(walker: Walker):
	var player_room = walker.get_player_room_position()
	for room in walker.rooms:
		if randf_range(0,1)<0.2 and room.position != player_room:
			var slime = SLIME.instantiate()
			slime.position = (room.position+random_position())*32
			enemies.add_child(slime)
			
func spawn_collectables(walker: Walker):
	pass

func random_position():
	var x = int(randi_range(0, 1))
	var y = int(randi_range(0, 1))
	return Vector2(x, y)
	
func spawn_exit(walker: Walker):
	var exit = ExitScene.instantiate()
	exit.position = walker.get_end_room().position*32
	lights.add_child(exit)
