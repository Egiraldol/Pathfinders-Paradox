extends Node2D

@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var camera = $"../Player/Camera2D"

var size: int = GlobalSettings.level_size
var source_id: int = 0
var maze: Array = []

var floor_atlas_options = [
	Vector2i(3, 3), Vector2i(3, 0), Vector2i(3, 2), Vector2i(3, 1),
	Vector2i(0, 3), Vector2i(0, 1), Vector2i(2, 1), Vector2i(2, 3),
	Vector2i(2, 0), Vector2i(2, 2), Vector2i(1, 0), Vector2i(1, 3),
	Vector2i(1, 2), Vector2i(1, 1), Vector2i(0, 2), Vector2i(0, 0)
]

var wall_atlas_options = [
	Vector2i(8, 0), Vector2i(8, 1), Vector2i(8, 2),
	Vector2i(8, 3), Vector2i(9, 0), Vector2i(9, 1)
]

func _ready() -> void:
	generate_level()
	await get_tree().process_frame

	var tile_size = 16
	var maze_width_pixels = (size * 2 + 1) * tile_size
	var maze_height_pixels = (size * 2 + 1) * tile_size
	
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = maze_width_pixels
	camera.limit_bottom = maze_height_pixels

func generate_level():
	maze = generate_maze(size, size)  # 🔥 Save maze globally

	for x in range(size * 2 + 1):
		for y in range(size * 2 + 1):
			if maze[y][x] == 1:
				var random_wall = wall_atlas_options[randi() % wall_atlas_options.size()]
				tile_map_layer.set_cell(Vector2i(x, y), source_id, random_wall)
			else:
				var sprite_index = get_floor_sprite(maze, x, y)
				tile_map_layer.set_cell(Vector2i(x, y), source_id, floor_atlas_options[sprite_index])

	generate_collectibles()
	spawn_flag_at_exit()

func generate_maze(width: int, height: int) -> Array:
	var maze = []
	for y in range(height * 2 + 1):
		var row = []
		for x in range(width * 2 + 1):
			row.append(1)
		maze.append(row)

	var stack = []
	var start_x = randi() % (width - 1) * 2 + 1
	var start_y = randi() % (height - 1) * 2 + 1
	maze[start_y][start_x] = 0
	stack.append(Vector2(start_x, start_y))

	var directions = [Vector2(2, 0), Vector2(-2, 0), Vector2(0, 2), Vector2(0, -2)]

	while stack.size() > 0:
		var current = stack[-1]
		var x = current.x
		var y = current.y
		var possible_moves = []

		for dir in directions:
			var nx = x + dir.x
			var ny = y + dir.y
			if nx >= 1 and nx < width * 2 and ny >= 1 and ny < height * 2 and maze[ny][nx] == 1:
				possible_moves.append(dir)

		if possible_moves.size() > 0:
			var dir = possible_moves[randi() % possible_moves.size()]
			maze[y + int(dir.y / 2)][x + int(dir.x / 2)] = 0
			maze[y + dir.y][x + dir.x] = 0
			stack.append(Vector2(x + dir.x, y + dir.y))
		else:
			stack.pop_back()

	# Create entrance
	maze[2][1] = 0
	maze[2][0] = 0

	# Create exit
	maze[height * 2 - 2][width * 2 - 1] = 0
	maze[height * 2 - 2][width * 2] = 0

	return maze

func get_floor_sprite(maze: Array, x: int, y: int) -> int:
	var neighbor_floors = []

	if y > 0 and maze[y - 1][x] == 0:
		neighbor_floors.append("up")
	if y < maze.size() - 1 and maze[y + 1][x] == 0:
		neighbor_floors.append("down")
	if x > 0 and maze[y][x - 1] == 0:
		neighbor_floors.append("left")
	if x < maze[0].size() - 1 and maze[y][x + 1] == 0:
		neighbor_floors.append("right")

	match neighbor_floors.size():
		1:
			match neighbor_floors[0]:
				"up":
					return 0
				"down":
					return 1
				"left":
					return 2
				"right":
					return 3
		2:
			if "up" in neighbor_floors and "down" in neighbor_floors:
				return 4
			elif "left" in neighbor_floors and "right" in neighbor_floors:
				return 5
			elif "up" in neighbor_floors and "left" in neighbor_floors:
				return 6
			elif "up" in neighbor_floors and "right" in neighbor_floors:
				return 7
			elif "down" in neighbor_floors and "left" in neighbor_floors:
				return 8
			elif "down" in neighbor_floors and "right" in neighbor_floors:
				return 9
		3:
			if "up" not in neighbor_floors:
				return 10
			elif "down" not in neighbor_floors:
				return 11
			elif "left" not in neighbor_floors:
				return 12
			elif "right" not in neighbor_floors:
				return 13
		4:
			return 14
		_:
			return 15

	return 15  # fallback

func spawn_flag_at_exit():
	var flag = preload("res://scenes/flag.tscn").instantiate()
	add_child(flag)

	var tile_size = 16
	var exit_x = (size * 2)
	var exit_y = (size * 2) - 2

	flag.position = Vector2(exit_x * tile_size + tile_size / 2, exit_y * tile_size + tile_size / 2)

func generate_collectibles():
	var collectible_scene = preload("res://scenes/Collectible.tscn")
	var tile_size = 16
	var number_of_collectibles = size

	for i in range(number_of_collectibles):
		var collectible = collectible_scene.instantiate()
		add_child(collectible)

		while true:
			var x = randi() % (size * 2 + 1)
			var y = randi() % (size * 2 + 1)

			# Only spawn if it's a floor
			if maze[y][x] == 0:
				collectible.position = Vector2(x * tile_size + tile_size / 2, y * tile_size + tile_size / 2)
				break
