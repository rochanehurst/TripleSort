extends Node3D

const SLOTS_PER_ROW: int = 6
const ROW_COUNT: int = 3
const SLOT_SIZE: float = 1.1

var depth_index: int = 0      # 0 = front, 1 = back, etc.
var slots: Array = []         # 2D array [row][col] of slot data

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
	for row in ROW_COUNT:
		for col in range(SLOTS_PER_ROW - 2):
			var a = slots[row][col]
			var b = slots[row][col + 1]
			var c = slots[row][col + 2]
			if a != null and b != null and c != null:
				if a.type_id == b.type_id and b.type_id == c.type_id:
					_clear_match(row, col)
					return

func _clear_match(row: int, start_col: int) -> void:
	for col in range(start_col, start_col + 3):
		var obj = slots[row][col]
		if obj != null:
			slots[row][col] = null
			obj.play_match_animation()
	EventBus.match_found.emit(slots[row][start_col].type_id if slots[row][start_col] else "")
	GameState.add_score(100)
	EventBus.emit_signal("board_changed")
