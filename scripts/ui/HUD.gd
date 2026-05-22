extends CanvasLayer

@onready var score_label: Label = $ScoreLabel
@onready var level_label: Label = $LevelLabel
@onready var restart_button: Button = $RestartButton

func _ready() -> void:
	EventBus.score_changed.connect(_on_score_changed)
	EventBus.level_completed.connect(_on_level_completed)
	EventBus.level_failed.connect(_on_level_failed)
	restart_button.pressed.connect(_on_restart_pressed)
	_update_labels()

func _update_labels() -> void:
	score_label.text = "Score: " + str(GameState.score)
	level_label.text = "Level: " + str(GameState.current_level)

func _on_score_changed(new_score: int) -> void:
	score_label.text = "Score: " + str(new_score)

func _on_level_completed() -> void:
	restart_button.text = "Next Level"
	restart_button.visible = true

func _on_level_failed() -> void:
	restart_button.text = "Try Again"
	restart_button.visible = true

func _on_restart_pressed() -> void:
	restart_button.visible = false
	get_tree().reload_current_scene()
