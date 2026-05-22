extends Control

const MAX_SLOTS: int = 7
var slots: Array = []

@onready var hbox: HBoxContainer = $HBoxContainer

signal slots_updated(slots: Array)

func _ready() -> void:
	EventBus.object_tapped.connect(_on_object_tapped)
	_rebuild_visual()

func _on_object_tapped(obj) -> void:
	add_to_slots(obj.type_id)

func add_to_slots(type_id: String) -> void:
	slots.append(type_id)
	_check_for_match(type_id)
	if slots.size() >= MAX_SLOTS:
		EventBus.slots_full.emit()
	_rebuild_visual()

func _check_for_match(type_id: String) -> void:
	if slots.count(type_id) >= 3:
		_clear_matches(type_id)

func _clear_matches(type_id: String) -> void:
	var removed = 0
	while removed < 3:
		var idx = slots.find(type_id)
		if idx == -1:
			break
		slots.remove_at(idx)
		removed += 1
	EventBus.match_found.emit(type_id)
	GameState.add_score(100)

func _rebuild_visual() -> void:
	for child in hbox.get_children():
		child.queue_free()
	for i in MAX_SLOTS:
		var panel = ColorRect.new()
		panel.custom_minimum_size = Vector2(60, 60)
		if i < slots.size():
			panel.color = Color(0.2, 0.8, 0.4)  # filled = green
		else:
			panel.color = Color(0.15, 0.15, 0.15)  # empty = dark
		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 4)
		margin.add_theme_constant_override("margin_right", 4)
		margin.add_child(panel)
		hbox.add_child(margin)

func is_full() -> bool:
	return slots.size() >= MAX_SLOTS

func reset() -> void:
	slots.clear()
	_rebuild_visual()
