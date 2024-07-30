extends Node2D


@onready var player = $SubViewportContainer/LightView/Player
@onready var lights = $SubViewportContainer/LightView/Lights
@onready var healthAndShieldGui = $CanvasLayer/HUD/HpAndShieldGui
@onready var visibility_tile_map = $SubViewportContainer/VisibilityViewport/VisibilityTileMap
@onready var tile_map = $SubViewportContainer/LightView/TileMap

@export var map_width: int = 30
@export var map_height: int = 15
var TorchScene = preload("res://assets/scenes/torch.tscn")
var dungeonGenerator: DungeonGenerator = DungeonGenerator.new()

func _ready():
	generate_map()
	healthAndShieldGui.setMaxHealth(player.maxHealth)
	healthAndShieldGui.updateHealth(player.currentHealth)
	healthAndShieldGui.setMaxShield(player.maxShield)
	healthAndShieldGui.updateShield(player.currentShield)
	player.healthChanged.connect(healthAndShieldGui.updateHealth)
	player.shieldChanged.connect(healthAndShieldGui.updateShield)
	for torch in lights.get_children():
		torch.enteredLight.connect(player.torch_area_entered)
		torch.exitedLight.connect(player.torch_area_exited)

func generate_map():
	var walker: Walker = dungeonGenerator.generate(visibility_tile_map, tile_map, map_width, map_height)
	place_player(walker)
	spawn_exit(walker)
	
	walker.queue_free()

func place_player(walker: Walker):
	player.position = walker.get_player_position()

func spawn_exit(walker: Walker):
	var torch = TorchScene.instantiate()
	torch.position = walker.get_end_room().position*32 + Vector2(0,16)
	lights.add_child(torch)
	print(torch.position)
