extends Node2D


@onready var player = $SubViewportContainer/LightView/Player
@onready var lights = $SubViewportContainer/LightView/Lights
@onready var healthAndShieldGui = $CanvasLayer/HUD/HpAndShieldGui
@onready var visibility_tile_map = $SubViewportContainer/VisibilityViewport/VisibilityTileMap
@onready var tile_map = $SubViewportContainer/LightView/TileMap
@onready var enemies = $SubViewportContainer/LightView/Enemies
@onready var collectables = $SubViewportContainer/LightView/Collectables

@export var map_width: int = 30
@export var map_height: int = 15

const GROUND_LAYER: int = 0

const TILE_SIZE: int = 32
const TORCH = preload("res://assets/scenes/torch.tscn")
const EXIT = preload("res://assets/scenes/exit.tscn")
const SLIME = preload("res://assets/scenes/enemies/slime.tscn")

# POTIONS
const BIG_DAMAGE_POTION = preload("res://assets/scenes/collectables/potions/big_damage_potion.tscn")
const BIG_IMMUNITY_POTION = preload("res://assets/scenes/collectables/potions/big_immunity_potion.tscn")
const BIG_LIFE_POTION = preload("res://assets/scenes/collectables/potions/big_life_potion.tscn")
const BIG_SHIELD_POTION = preload("res://assets/scenes/collectables/potions/big_shield_potion.tscn")
const BIG_SPEED_POTION = preload("res://assets/scenes/collectables/potions/big_speed_potion.tscn")
const DAMAGE_POTION = preload("res://assets/scenes/collectables/potions/damage_potion.tscn")
const IMMUNITY_POTION = preload("res://assets/scenes/collectables/potions/immunity_potion.tscn")
const LIFE_POTION = preload("res://assets/scenes/collectables/potions/life_potion.tscn")
const SHIELD_POTION = preload("res://assets/scenes/collectables/potions/shield_potion.tscn")
const SMALL_DAMAGE_POTION = preload("res://assets/scenes/collectables/potions/small_damage_potion.tscn")
const SMALL_IMMUNITY_POTION = preload("res://assets/scenes/collectables/potions/small_immunity_potion.tscn")
const SMALL_LIFE_POTION = preload("res://assets/scenes/collectables/potions/small_life_potion.tscn")
const SMALL_SHIELD_POTION = preload("res://assets/scenes/collectables/potions/small_shield_potion.tscn")
const SMALL_SPEED_POTION = preload("res://assets/scenes/collectables/potions/small_speed_potion.tscn")
const SPEED_POTION = preload("res://assets/scenes/collectables/potions/speed_potion.tscn")
const POTIONS: Array[PackedScene] = [
	BIG_DAMAGE_POTION, 
	BIG_IMMUNITY_POTION,
	BIG_LIFE_POTION,
	BIG_SHIELD_POTION,
	BIG_SPEED_POTION,
	DAMAGE_POTION,
	IMMUNITY_POTION,
	LIFE_POTION,
	SHIELD_POTION,
	SMALL_DAMAGE_POTION,
	SMALL_IMMUNITY_POTION,
	SMALL_LIFE_POTION,
	SMALL_SHIELD_POTION,
	SMALL_SPEED_POTION,
	SPEED_POTION
	]

# RUNES
const ALGIZ_RUNE = preload("res://assets/scenes/collectables/runes/algiz_rune.tscn")
const ISA_RUNE = preload("res://assets/scenes/collectables/runes/isa_rune.tscn")
const LAGUZ_RUNE = preload("res://assets/scenes/collectables/runes/laguz_rune.tscn")
const NAUTHIZ_RUNE = preload("res://assets/scenes/collectables/runes/nauthiz_rune.tscn")
const RERTH_RUNE = preload("res://assets/scenes/collectables/runes/rerth_rune.tscn")
const SOWELU_RUNE = preload("res://assets/scenes/collectables/runes/sowelu_rune.tscn")
const TEIWAZ_RUNE = preload("res://assets/scenes/collectables/runes/teiwaz_rune.tscn")
const URUS_RUNE = preload("res://assets/scenes/collectables/runes/urus_rune.tscn")
const RUNES: Array[PackedScene] = [
	ALGIZ_RUNE,
	ISA_RUNE,
	LAGUZ_RUNE,
	NAUTHIZ_RUNE,
	RERTH_RUNE,
	SOWELU_RUNE,
	TEIWAZ_RUNE,
	URUS_RUNE
	]

var player_room: Vector2
var exit_room: Vector2
var busy_positions: Array[Vector2] = []
var dungeonGenerator: DungeonGenerator = DungeonGenerator.new()

func _ready():
	generate_map()
	_connect_signals()

func _connect_signals():
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
	player_room = walker.get_player_room_position()
	exit_room = walker.get_end_room().position
	_place_player(walker)
	_spawn_exit(walker)
	_spawn_lights(walker)
	_spawn_monsters(walker)
	_spawn_collectables(walker)
	
	walker.queue_free()

func _place_player(walker: Walker):
	print("player: ", player_room)
	player.position = player_room*TILE_SIZE
	add_safe_positions(player_room)

func _spawn_lights(walker: Walker):
	_spawn_multiple(walker, [TORCH], lights, 0.05, false)

func _spawn_monsters(walker: Walker):
	_spawn_multiple(walker, [SLIME], enemies, 0.2, true)
			
func _spawn_collectables(walker: Walker):
	_spawn_multiple(walker, POTIONS, collectables, 0.2, true)

func _spawn_multiple(walker: Walker, THINGS: Array[PackedScene], parent: Node, chance: float, randomize: bool):
	var randomized_position: Vector2
	var tries_amount: int
	for room in walker.rooms:
		if randf_range(0,1) < chance and room.position not in [player_room, exit_room]:
			
			var tile_position = room.position 
			
			if randomize:
				randomized_position = tile_position + random_position()
				tries_amount = 5
				
				while tries_amount > 0 and tile_map.get_cell_atlas_coords(GROUND_LAYER, randomized_position) != Vector2i(-1, -1):
					randomized_position = tile_position + random_position()
					tries_amount -= 1
				tile_position = randomized_position
				
			if tile_position not in busy_positions:
				var random_index = randi_range(0, THINGS.size() - 1)
				var thing = THINGS[random_index].instantiate()
				thing.position = tile_position * TILE_SIZE
				parent.add_child(thing)
				busy_positions.append(tile_position)
				if thing is Enemy:
					thing.spawn_collectable.connect(_spawn_rune_at_place)

func _spawn_exit(walker: Walker):
	var exit = EXIT.instantiate()
	exit.position = exit_room * TILE_SIZE
	lights.add_child(exit)
	add_safe_positions(exit_room)

func _spawn_rune_at_place(spawn_position: Vector2):
	if randf_range(0,1) < 0.5:
		var random_index = randi_range(0, RUNES.size() - 1)
		var rune = RUNES[random_index].instantiate()
		rune.position = spawn_position
		collectables.add_child(rune)

func random_position() -> Vector2:
	var x = int(randi_range(0, 1))
	var y = int(randi_range(0, 1))
	return Vector2(x, y)

func add_safe_positions(base_vector: Vector2):
	var vectors: Array = []
	var base_x = base_vector.x
	var base_y = base_vector.y
	
	# Iterate over the range of x and y values
	for x in range(int(base_x) - 3, int(base_x) + 4):
		for y in range(int(base_y) - 3, int(base_y) + 4):
			busy_positions.append(Vector2(x, y))
