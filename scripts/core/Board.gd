extends Node3D

const SHELF_SPACING_Z: float = 0.6
const SHELF_SPACING_Y: float = 4.0

@onready var object_container: Node3D = $ObjectContainer
@onready var camera: Camera3D = $Camera3D

var shelves: Array = []
var _dragging_object = null
var _drag_origin_shelf = null
var _drag_origin_row: int = -1
var _drag_origin_col: int = -1
var _drag_plane: Plane

func _ready() -> void:
	EventBus.connect("board_changed", _on_board_changed)

func setup_shelves(shelf_scene: PackedScene, shelf_count: int) -> void:
	for i in shelf_count:
		var shelf = shelf_scene.instantiate()
		object_container.add_child(shelf)
		shelf.position = Vector3(0, -i * SHELF_SPACING_Y, -i * SHELF_SPACING_Z)
		shelf.setup(i)
		shelves.append(shelf)

func spawn_objects_at_slots(object_scene: PackedScene, type_ids: Array, slot_list: Array) -> void:
	var type_colors = {
		"type_a": Color(1, 0.2, 0.2),
		"type_b": Color(0.2, 0.5, 1),
		"type_c": Color(0.2, 0.9, 0.2),
		"type_d": Color(1, 0.8, 0.1),
		"type_e": Color(1, 0.4, 0.1),
		"type_f": Color(0.8, 0.2, 1),
	}
	for idx in type_ids.size():
		var slot = slot_list[idx]
		var shelf = shelves[slot.shelf]
		var obj = object_scene.instantiate()
		object_container.add_child(obj)
		obj.type_id = type_ids[idx]
		var mat = StandardMaterial3D.new()
		mat.albedo_color = ThemeLoader.get_color_for_type(obj.type_id)
		mat.roughness = 0.7
		mat.metallic = 0.1
		obj.get_node("MeshInstance3D").material_override = mat
		var world_pos = shelf.get_slot_world_position(slot.row, slot.col)
		obj.position = world_pos
		obj.rotation.y = randf_range(-0.15, 0.15)
		shelf.place_object(obj, slot.row, slot.col)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_try_start_drag(event.position)
		elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_try_drop()
	elif event is InputEventScreenTouch:
		if event.pressed:
			_try_start_drag(event.position)
		else:
			_try_drop()
	elif event is InputEventMouseMotion and _dragging_object != null:
		_update_drag(event.position)
	elif event is InputEventScreenDrag and _dragging_object != null:
		_update_drag(event.position)

func _try_start_drag(screen_pos: Vector2) -> void:
	var from = camera.project_ray_origin(screen_pos)
	var to = from + camera.project_ray_normal(screen_pos) * 100.0
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space.intersect_ray(query)
	if result and result.collider is StaticBody3D:
		var obj = result.collider
		if obj.has_method("start_drag") and not obj.is_blocked:
			_dragging_object = obj
			_drag_origin_shelf = obj.current_shelf
			_drag_origin_row = obj.grid_row
			_drag_origin_col = obj.grid_col
			_drag_origin_shelf.remove_object(_drag_origin_row, _drag_origin_col)
			_drag_plane = Plane(Vector3(0, 0, 1), obj.global_position.z)
			obj.start_drag()

func _update_drag(screen_pos: Vector2) -> void:
	var from = camera.project_ray_origin(screen_pos)
	var dir = camera.project_ray_normal(screen_pos)
	var hit = _drag_plane.intersects_ray(from, dir)
	if hit:
		_dragging_object.global_position = hit

func _try_drop() -> void:
	if _dragging_object == null:
		return
	var best_shelf = null
	var best_row = -1
	var best_col = -1
	var best_dist = INF

	for shelf in shelves:
		for row in shelf.ROW_COUNT:
			for col in shelf.SLOTS_PER_ROW:
				if not shelf.is_slot_empty(row, col):
					continue
				var slot_pos = shelf.get_slot_world_position(row, col)
				var drag_pos_2d = Vector2(_dragging_object.global_position.x, _dragging_object.global_position.y)
				var slot_pos_2d = Vector2(slot_pos.x, slot_pos.y)
				var dist = drag_pos_2d.distance_to(slot_pos_2d)
				if dist < best_dist:
					best_dist = dist
					best_shelf = shelf
					best_row = row
					best_col = col

	if best_shelf != null and best_dist < best_shelf.SLOT_SIZE * 1.5:
		best_shelf.place_object(_dragging_object, best_row, best_col)
		_dragging_object.global_position = best_shelf.get_slot_world_position(best_row, best_col)
		_dragging_object.end_drag()
		best_shelf.check_matches()
		_dragging_object = null
	else:
		_drag_origin_shelf.place_object(_dragging_object, _drag_origin_row, _drag_origin_col)
		_dragging_object.global_position = _drag_origin_shelf.get_slot_world_position(
			_drag_origin_row, _drag_origin_col)
		_dragging_object.end_drag()
		_dragging_object = null

func _on_board_changed() -> void:
	_check_win()

func _check_win() -> void:
	for shelf in shelves:
		for row in shelf.ROW_COUNT:
			for col in shelf.SLOTS_PER_ROW:
				if not shelf.is_slot_empty(row, col):
					return
	EventBus.level_completed.emit()

func clear_board() -> void:
	for shelf in shelves:
		if is_instance_valid(shelf):
			shelf.queue_free()
	shelves.clear()
