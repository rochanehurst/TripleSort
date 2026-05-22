extends Node

@export var match_object_scene: PackedScene
@export var shelf_scene: PackedScene
@export var shelf_count: int = 3

var _board: Node3D

func _ready() -> void:
	EventBus.level_completed.connect(_on_level_completed)
	EventBus.level_failed.connect(_on_level_failed)

func setup(board: Node3D) -> void:
	_board = board

func start_level() -> void:
	GameState.reset_for_level()
	_board.clear_board()
	_board.setup_shelves(shelf_scene, shelf_count)

	# Build slot positions and shuffle them so empty slots are random
	var all_slots = []
	for shelf_idx in shelf_count:
		for row in 3:
			for col in 3:
				all_slots.append({"shelf": shelf_idx, "row": row, "col": col})
	all_slots.shuffle()

	# 3 shelves x 3 rows x 3 cols = 27 slots
	# Use 24 slots (8 per type x 3 types), leave 3 empty
	var types = ["type_a", "type_b", "type_c"]
	var type_ids = []
	for t in types:
		for i in 8:
			type_ids.append(t)
	type_ids.shuffle()

	_board.spawn_objects_at_slots(match_object_scene, type_ids, all_slots)
	EventBus.level_started.emit()

func _on_level_completed() -> void:
	print("Level complete! Score: ", GameState.score)
	GameState.current_level += 1

func _on_level_failed() -> void:
	print("Level failed!")
