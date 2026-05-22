extends StaticBody3D

# === DATA ===
var type_id: String = ""        # e.g. "seashell", "crab", "bucket"
var is_collected: bool = false

# === NODES ===
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var anim: AnimationPlayer = $AnimationPlayer

func setup(id: String, mesh_resource: Mesh, material: Material) -> void:
	type_id = id
	mesh.mesh = mesh_resource
	mesh.material_override = material

func on_tapped() -> void:
	if is_collected:
		return
	is_collected = true
	EventBus.object_tapped.emit(self)
	_play_collect_animation()

func _play_collect_animation() -> void:
	# Placeholder — we'll add real animations soon
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.2)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_IN)
	tween.tween_callback(queue_free)

func highlight(on: bool) -> void:
	if on:
		mesh.material_override.emission_enabled = true
	else:
		mesh.material_override.emission_enabled = false
