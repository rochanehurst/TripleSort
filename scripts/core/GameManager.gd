extends Node

@export var match_object_scene: PackedScene

var _board: Node3D

func _ready() -> void:
	EventBus.level_completed.connect(_on_level_completed)
	EventBus.level_failed.connect(_on_level_failed)

func setup(board: Node3D) -> void:
	_board = board

func start_level() -> void:
	GameState.reset_for_level()
	_board.clear_board()
	EventBus.level_started.emit()

func _on_level_completed() -> void:
	print("Level complete! Score: ", GameState.score)
	GameState.current_level += 1

func _on_level_failed() -> void:
	print("Level failed!")
