extends StaticBody3D

# === DATA ===
var type_id: String = ""
var is_collected: bool = false
var is_blocked: bool = false

# === GRID POSITION ===
var grid_col: int = 0
var grid_row: int = 0
var grid_layer: int = 0

# === CALLBACK ===
var on_removed_callback: Callable

# === NODES ===
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var anim: AnimationPlayer = $AnimationPlayer

func set_blocked(blocked: bool) -> void:
	is_blocked = blocked
	# Visual feedback — blocked objects appear darker
	if mesh.material_override:
		var mat = mesh.material_override as StandardMaterial3D
		if mat:
			mat.albedo_color.a = 0.4 if blocked else 1.0
			mesh.material_override = mat

func on_tapped() -> void:
	print("Tapped! is_collected=", is_collected, " is_blocked=", is_blocked)
	if is_collected or is_blocked:
		return
	is_collected = true
	EventBus.object_tapped.emit(self)
	_play_collect_animation()
	
func _play_collect_animation() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.2)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_IN)
	tween.tween_callback(_on_collect_finished)

func _on_collect_finished() -> void:
	if on_removed_callback.is_valid():
		on_removed_callback.call(grid_col, grid_row, grid_layer)
	queue_free()

func highlight(on: bool) -> void:
	if mesh.material_override:
		var mat = mesh.material_override as StandardMaterial3D
		if mat:
			mat.emission_enabled = on
