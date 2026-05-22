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

	# Load theme
	ThemeLoader.load_theme(GameState.current_theme)
	var object_types = ThemeLoader.get_object_types()

	# Build slot list and shuffle
	var all_slots = []
	for shelf_idx in shelf_count:
		for row in 3:
			for col in 3:
				all_slots.append({"shelf": shelf_idx, "row": row, "col": col})
	all_slots.shuffle()

	# Fill slots with guaranteed sets of 3
	# 27 slots total, use 24 (leave 3 empty)
	var type_ids = []
	for i in 8:
		var obj_type = object_types[i % object_types.size()]
		for j in 3:
			type_ids.append(obj_type.type_id)
	type_ids.shuffle()

	_board.spawn_objects_at_slots(match_object_scene, type_ids, all_slots)
	EventBus.level_started.emit()

func _on_level_completed() -> void:
	print("Level complete! Score: ", GameState.score)
	GameState.current_level += 1

func _on_level_failed() -> void:
	print("Level failed!")
