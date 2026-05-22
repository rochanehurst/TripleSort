extends Node3D

const COLS: int = 6
const ROWS: int = 7
const LAYERS: int = 3

const CELL_SIZE_X: float = 1.1
const CELL_SIZE_Y: float = 1.1
const LAYER_OFFSET_X: float = 0.15
const LAYER_OFFSET_Y: float = 0.15
const LAYER_OFFSET_Z: float = 0.5

@onready var object_container: Node3D = $ObjectContainer
@onready var camera: Camera3D = $Camera3D

var _grid: Array = []
var _active_objects: Array = []

func _ready() -> void:
	EventBus.match_found.connect(_on_match_found)
	EventBus.slots_full.connect(_on_slots_full)
	_init_grid()

func _init_grid() -> void:
	_grid.clear()
	for layer in LAYERS:
		var layer_data = []
		for row in ROWS:
			var row_data = []
			for col in COLS:
				row_data.append(null)
			layer_data.append(row_data)
		_grid.append(layer_data)

func spawn_objects(object_scene: PackedScene, type_ids: Array) -> void:
	var type_colors = {
		"type_a": Color(1, 0.2, 0.2),
		"type_b": Color(0.2, 0.5, 1),
		"type_c": Color(0.2, 0.9, 0.2),
		"type_d": Color(1, 0.8, 0.1),
		"type_e": Color(1, 0.4, 0.1),
		"type_f": Color(0.8, 0.2, 1),
	}
	var idx = 0
	for layer in LAYERS:
		for row in ROWS:
			for col in COLS:
				if idx >= type_ids.size():
					return
				var obj = object_scene.instantiate()
				object_container.add_child(obj)
				obj.type_id = type_ids[idx]
				obj.position = _grid_to_world(col, row, layer)
				var mat = StandardMaterial3D.new()
				mat.albedo_color = type_colors.get(obj.type_id, Color(1,1,1))
				obj.get_node("MeshInstance3D").material_override = mat
				_grid[layer][row][col] = obj
				_active_objects.append(obj)
				obj.grid_col = col
				obj.grid_row = row
				obj.grid_layer = layer
				obj.on_removed_callback = _on_object_removed
				_update_blocked_state(col, row, layer, obj)
				idx += 1
				
func _grid_to_world(col: int, row: int, layer: int) -> Vector3:
	var board_width = COLS * CELL_SIZE_X
	var board_height = ROWS * CELL_SIZE_Y
	var x = (col * CELL_SIZE_X) - (board_width / 2.0) + (layer * LAYER_OFFSET_X)
	var y = -(row * CELL_SIZE_Y) + (board_height / 2.0) - (layer * LAYER_OFFSET_Y)
	var z = layer * LAYER_OFFSET_Z
	return Vector3(x, y, z)

func _update_blocked_state(col: int, row: int, layer: int, obj) -> void:
	if layer == 0:
		obj.set_blocked(false)
		return
	var blocked = _has_front_neighbor(col, row, layer)
	obj.set_blocked(blocked)

func _has_front_neighbor(col: int, row: int, layer: int) -> bool:
	for front_layer in range(0, layer):
		for dc in [-1, 0, 1]:
			for dr in [-1, 0, 1]:
				var nc = col + dc
				var nr = row + dr
				if nc < 0 or nc >= COLS or nr < 0 or nr >= ROWS:
					continue
				if _grid[front_layer][nr][nc] != null:
					return true
	return false

func refresh_blocking() -> void:
	for layer in LAYERS:
		for row in ROWS:
			for col in COLS:
				var obj = _grid[layer][row][col]
				if obj != null and is_instance_valid(obj):
					_update_blocked_state(col, row, layer, obj)

func _on_object_removed(col: int, row: int, layer: int) -> void:
	_grid[layer][row][col] = null
	refresh_blocking()
	_active_objects = _active_objects.filter(
		func(o): return o != null and is_instance_valid(o) and not o.is_collected
	)
	if _active_objects.is_empty():
		EventBus.level_completed.emit()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		_handle_tap(event.position)
	elif event is InputEventMouseButton and event.pressed:
		_handle_tap(event.position)

func _handle_tap(screen_pos: Vector2) -> void:
	print("Tap at: ", screen_pos)
	var from = camera.project_ray_origin(screen_pos)
	var to = from + camera.project_ray_normal(screen_pos) * 100.0
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space.intersect_ray(query)
	print("Ray result: ", result)
	if result and result.collider is StaticBody3D:
		var obj = result.collider
		if obj.has_method("on_tapped") and not obj.is_blocked:
			obj.on_tapped()

func _on_match_found(_type_id: String) -> void:
	pass

func _on_slots_full() -> void:
	EventBus.level_failed.emit()

func clear_board() -> void:
	for obj in _active_objects:
		if is_instance_valid(obj):
			obj.queue_free()
	_active_objects.clear()
	_init_grid()
