extends Node

@export var match_object_scene: PackedScene

var _board: Node3D
var _slot_bar

func _ready() -> void:
	EventBus.level_completed.connect(_on_level_completed)
	EventBus.level_failed.connect(_on_level_failed)

func setup(board: Node3D, slot_bar) -> void:
	_board = board
	_slot_bar = slot_bar

func start_level() -> void:
	GameState.reset_for_level()
	_slot_bar.reset()
	_board.clear_board()

	# Build guaranteed-matchable type list for 6x7x3 = 126 slots
	# 126 / 3 = 42 sets of 3, using 6 types = 7 sets per type
	var type_ids = []
	var types = ["type_a", "type_b", "type_c", "type_d", "type_e", "type_f"]
	for t in types:
		for i in 21:  # 21 × 3 = 63 per half, but we need 126 total / 6 types = 21 each
			type_ids.append(t)
	type_ids.shuffle()
	_board.spawn_objects(match_object_scene, type_ids)
	EventBus.level_started.emit()

func _on_level_completed() -> void:
	print("Level complete! Score: ", GameState.score)
	GameState.current_level += 1

func _on_level_failed() -> void:
	print("Level failed!")
