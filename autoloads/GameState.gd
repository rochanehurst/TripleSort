extends Node

# === LEVEL ===
var current_level: int = 1
var current_theme: String = "beach"

# === SCORE ===
var score: int = 0
var high_score: int = 0

# === RESOURCES ===
var hints_remaining: int = 3
var lives_remaining: int = 3

# === SESSION ===
var is_paused: bool = false

func _ready() -> void:
	_load_persistent_data()

func add_score(points: int) -> void:
	score += points
	if score > high_score:
		high_score = score
	EventBus.score_changed.emit(score)

func use_hint() -> bool:
	if hints_remaining > 0:
		hints_remaining -= 1
		return true
	return false

func reset_for_level() -> void:
	score = 0
	lives_remaining = 3

func _load_persistent_data() -> void:
	# We'll wire this to SaveManager later
	# For now just use defaults
	pass
