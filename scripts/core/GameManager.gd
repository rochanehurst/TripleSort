extends Node

@export var match_object_scene: PackedScene
@export var shelf_scene: PackedScene
@export var shelf_count: int = 4

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
	ThemeLoader.load_theme(GameState.current_theme)
	var object_types = ThemeLoader.get_object_types()
	
	var all_slots = []
	for shelf_idx in shelf_count:
		for row in 3:
			for col in 3:
				all_slots.append({"shelf": shelf_idx, "row": row, "col": col})
	all_slots.shuffle()
	
	# 27 filled slots out of 36 total
	var type_ids = []
	for i in 9:
		var obj_type = object_types[i % object_types.size()]
		for j in 3:
			type_ids.append(obj_type.type_id)
	type_ids.shuffle()
	
	# only fill first 27 slots, leave 9 empty
	_board.spawn_objects_at_slots(match_object_scene, type_ids, all_slots.slice(0, 27))
	EventBus.level_started.emit()

func _on_level_completed() -> void:
	print("Level complete! Score: ", GameState.score)
	GameState.current_level += 1

func _on_level_failed() -> void:
	print("Level failed!")
