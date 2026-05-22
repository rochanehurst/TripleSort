extends StaticBody3D

# === DATA ===
var type_id: String = ""
var is_collected: bool = false
var is_blocked: bool = false

# === GRID POSITION ===
var grid_row: int = 0
var grid_col: int = 0
var current_shelf = null

# === NODES ===
@onready var mesh: MeshInstance3D = $MeshInstance3D

func set_blocked(blocked: bool) -> void:
	is_blocked = blocked
	if mesh.material_override:
		var mat = mesh.material_override as StandardMaterial3D
		if mat:
			mat.albedo_color.a = 0.35 if blocked else 1.0

func start_drag() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3(1.15, 1.15, 1.15), 0.1)

func end_drag() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ONE, 0.1)

func play_match_animation() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3(1.3, 1.3, 1.3), 0.1)
	tween.tween_property(self, "scale", Vector3.ZERO, 0.15)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_IN)
	tween.tween_callback(queue_free)
