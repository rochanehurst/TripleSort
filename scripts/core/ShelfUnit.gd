extends Node3D

const SLOTS_PER_ROW: int = 3
const ROW_COUNT: int = 3
const SLOT_SIZE: float = 1.1

var depth_index: int = 0
var slots: Array = []

@onready var slots_container: Node3D = $SlotsContainer

func setup(depth: int) -> void:
	depth_index = depth
	slots.clear()
	for row in ROW_COUNT:
		var row_data = []
		for col in SLOTS_PER_ROW:
			row_data.append(null)
		slots.append(row_data)

func get_slot_world_position(row: int, col: int) -> Vector3:
	var x = (col - (SLOTS_PER_ROW / 2.0) + 0.5) * SLOT_SIZE
	var y = -(row - (ROW_COUNT / 2.0) + 0.5) * SLOT_SIZE
	var z = 0.0
	return global_position + Vector3(x, y, z)

func place_object(obj, row: int, col: int) -> void:
	slots[row][col] = obj
	obj.grid_row = row
	obj.grid_col = col
	obj.current_shelf = self

func remove_object(row: int, col: int) -> void:
	slots[row][col] = null

func is_slot_empty(row: int, col: int) -> bool:
	return slots[row][col] == null

func get_object(row: int, col: int):
	return slots[row][col]

func check_matches() -> void:
	# Clean stale references first
	for row in ROW_COUNT:
		for col in SLOTS_PER_ROW:
			if slots[row][col] != null and not is_instance_valid(slots[row][col]):
				slots[row][col] = null

	for row in ROW_COUNT:
		for col in range(SLOTS_PER_ROW - 2):
			var a = slots[row][col]
			var b = slots[row][col + 1]
			var c = slots[row][col + 2]
			if a == null or b == null or c == null:
				continue
			if a.type_id == b.type_id and b.type_id == c.type_id:
				_clear_match(row, col)
				return

func _clear_match(row: int, start_col: int) -> void:
	var matched_type = ""
	for col in range(start_col, start_col + 3):
		var obj = slots[row][col]
		if obj != null and is_instance_valid(obj):
			matched_type = obj.type_id
			slots[row][col] = null
			obj.play_match_animation()
	if matched_type != "":
		EventBus.match_found.emit(matched_type)
		GameState.add_score(100)
		EventBus.board_changed.emit()
