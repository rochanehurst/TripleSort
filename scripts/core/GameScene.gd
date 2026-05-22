extends Node

@onready var board: Node3D = $Board
@onready var game_manager = $GameManager

func _ready() -> void:
	game_manager.setup(board)
