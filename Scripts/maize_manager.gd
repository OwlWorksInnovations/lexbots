extends Node

var grid_width: int = 35
var grid_height: int = 35

const FLOOR = preload("uid://chjtwa2eiat50")
const WALLS = preload("uid://d4d4pmlvchhln")

var grid: Array = []

@export var loop_chance: float = 0.2

func _ready() -> void:
	randomize()
	grid = generate_grid(grid_width, grid_height)
	generate_maize()
	carve_loops()

	grid[1][1] = 1
	grid[0][1] = 1
	grid[grid_width - 2][grid_height - 2] = 1
	grid[grid_width - 1][grid_height - 2] = 1

	build_world()

func generate_grid(width: int, height: int):
	var new_grid = []
	for x in range(width):
		new_grid.append([])
		for y in range(height):
			new_grid[x].append(0)
	return new_grid

func generate_maize():
	var start_x = 1
	var start_y = 1
	grid[start_x][start_y] = 1

	var stack = [[start_x, start_y]]
	while !stack.is_empty():
		var current = stack.back()
		var valid_neighbour: Array = []

		if current[0] > 2 and grid[current[0] - 2][current[1]] == 0:
			valid_neighbour.append([current[0] - 2, current[1]])
		if current[0] < grid_width - 3 and grid[current[0] + 2][current[1]] == 0:
			valid_neighbour.append([current[0] + 2, current[1]])
		if current[1] > 2 and grid[current[0]][current[1] - 2] == 0:
			valid_neighbour.append([current[0], current[1] - 2])
		if current[1] < grid_height - 3 and grid[current[0]][current[1] + 2] == 0:
			valid_neighbour.append([current[0], current[1] + 2])

		if !valid_neighbour.is_empty():
			var res = valid_neighbour.pick_random()
			grid[res[0]][res[1]] = 1
			grid[(current[0] + res[0]) / 2][(current[1] + res[1]) / 2] = 1
			stack.append(res)
		else:
			stack.pop_back()

func carve_loops():
	for x in range(1, grid_width - 1):
		for y in range(1, grid_height - 1):
			if grid[x][y] == 1:
				continue

			var horizontal = grid[x - 1][y] == 1 and grid[x + 1][y] == 1
			var vertical = grid[x][y - 1] == 1 and grid[x][y + 1] == 1

			if (horizontal or vertical) and not (horizontal and vertical):
				if randf() < loop_chance:
					grid[x][y] = 1

func build_world():
	for x in range(grid_width):
		for y in range(grid_height):
			var pos = Vector3(x * 2.0, 0, y * 2.0)
			if grid[x][y] == 0:
				var wall = WALLS.instantiate()
				wall.position = pos + Vector3(0, 3, 0)
				add_child(wall)
			else:
				var floor_tile = FLOOR.instantiate()
				floor_tile.position = pos
				add_child(floor_tile)

	var exit_area = Area3D.new()
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(2, 2, 2)
	collision.shape = shape
	exit_area.add_child(collision)
	exit_area.position = Vector3((grid_width - 1) * 2.0, 0, (grid_height - 2) * 2.0)
	exit_area.body_entered.connect(_on_exit_reached)
	add_child(exit_area)

func _on_exit_reached(body: Node3D) -> void:
	if body is CharacterBody3D:
		print("Player reached the exit!")
