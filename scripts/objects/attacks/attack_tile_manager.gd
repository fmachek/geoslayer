class_name AttackTileManager
extends Node

## Size of each tile.
@export var tile_size: int
## Amount of tiles in each direction, from the center.
@export var map_extents: int
@export var tile_color: Color = Color.RED

const TILE_SCENE := preload("res://scenes/objects/attacks/attack_tile.tscn")

# Array of arrays of Area2D objects (tiles)
var tiles: Array = []


func _ready() -> void:
	generate_tiles()


func generate_tiles() -> void:
	var start_x: int = -map_extents * tile_size
	# Loop through rows and columns, assuming the map is a square
	for row in range(map_extents * 2):
		var row_array := []
		tiles.append(row_array)
		for column in range(map_extents * 2):
			var tile: AttackTile = TILE_SCENE.instantiate()
			tile.tile_size = tile_size
			tile.global_position = Vector2(
					column * tile_size - map_extents * tile_size,
					row * tile_size - map_extents * tile_size
			)
			tile.draw_color = tile_color 
			row_array.append(tile)
			add_child(tile)


func trigger_random_attack(damage: int) -> void:
	var attack_amount: int = pow(map_extents * 2, 2) * 2/3
	var eligible_tiles: Array[AttackTile] = []
	for row in tiles:
		eligible_tiles.append_array(row)
	for i in range(attack_amount):
		var tile: AttackTile = eligible_tiles.pick_random()
		eligible_tiles.erase(tile)
		tile.damage = damage
		tile.start_attack()
