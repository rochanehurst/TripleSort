extends Node

@onready var board: Node3D = $Board
@onready var slot_bar = $SlotBar
@onready var game_manager = $GameManager

func _ready() -> void:
	game_manager.setup(board, slot_bar)
	game_manager.start_level()
	print("Active camera: ", get_viewport().get_camera_3d())
