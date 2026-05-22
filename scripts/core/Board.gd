extends Node3D

@onready var object_container: Node3D = $ObjectContainer
@onready var camera: Camera3D = $Camera3D

var _active_objects: Array = []

func _ready() -> void:
	EventBus.match_found.connect(_on_match_found)
	EventBus.slots_full.connect(_on_slots_full)

func spawn_objects(object_scene: PackedScene, type_ids: Array, count: int) -> void:
	# Define a fixed color per type so matching is visually clear
	var type_colors = {
		"type_a": Color(1, 0.2, 0.2),    # red
		"type_b": Color(0.2, 0.5, 1),    # blue
		"type_c": Color(0.2, 0.9, 0.2),  # green
		"type_d": Color(1, 0.8, 0.1),    # yellow
		"type_e": Color(1, 0.4, 0.1),    # orange
		"type_f": Color(0.8, 0.2, 1),    # purple
	}
	for i in count:
		var obj = object_scene.instantiate()
		object_container.add_child(obj)
		obj.type_id = type_ids[i]
		obj.position = Vector3(
			randf_range(-3.0, 3.0),
			randf_range(-1.5, 1.5),
			randf_range(-1.0, 0.5)
		)
		var mat = StandardMaterial3D.new()
		mat.albedo_color = type_colors.get(obj.type_id, Color(1, 1, 1))
		obj.get_node("MeshInstance3D").material_override = mat
		_active_objects.append(obj)
		
func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		_handle_tap(event.position)
	elif event is InputEventMouseButton and event.pressed:
		_handle_tap(event.position)

func _handle_tap(screen_pos: Vector2) -> void:
	var from = camera.project_ray_origin(screen_pos)
	var to = from + camera.project_ray_normal(screen_pos) * 100.0
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space.intersect_ray(query)
	if result and result.collider is StaticBody3D:
		var obj = result.collider
		if obj.has_method("on_tapped"):
			obj.on_tapped()

func _on_match_found(type_id: String) -> void:
	_active_objects = _active_objects.filter(func(o): return o != null and not o.is_collected)
	if _active_objects.is_empty():
		EventBus.level_completed.emit()

func _on_slots_full() -> void:
	EventBus.level_failed.emit()

func clear_board() -> void:
	for obj in _active_objects:
		if is_instance_valid(obj):
			obj.queue_free()
	_active_objects.clear()
