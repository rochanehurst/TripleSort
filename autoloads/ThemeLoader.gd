extends Node

var current_theme: Dictionary = {}
var _mesh_cache: Dictionary = {}

func load_theme(theme_id: String) -> bool:
	var path = "res://assets/themes/" + theme_id + "/theme_data.json"
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("ThemeLoader: could not open " + path)
		return false
	var json = JSON.new()
	var result = json.parse(file.get_as_text())
	file.close()
	if result != OK:
		push_error("ThemeLoader: JSON parse error in " + path)
		return false
	current_theme = json.get_data()
	_mesh_cache.clear()
	print("ThemeLoader: loaded theme '", current_theme.theme_id, "' with ", current_theme.objects.size(), " object types")
	return true

func get_object_types() -> Array:
	if current_theme.is_empty():
		return []
	return current_theme.objects

func get_mesh_for_type(type_id: String) -> Mesh:
	if _mesh_cache.has(type_id):
		return _mesh_cache[type_id]
	var obj_data = _get_object_data(type_id)
	if obj_data.is_empty():
		return null
	var mesh_path = "res://assets/themes/" + current_theme.theme_id + "/models/" + obj_data.mesh
	if not ResourceLoader.exists(mesh_path):
		# Fallback to box mesh if GLB not found yet
		var box = BoxMesh.new()
		box.size = Vector3(0.8, 0.8, 0.8)
		return box
	var scene = load(mesh_path) as PackedScene
	if scene == null:
		return null
	var instance = scene.instantiate()
	var mesh_instance = instance.find_child("*", true, false) as MeshInstance3D
	var mesh = mesh_instance.mesh if mesh_instance else null
	_mesh_cache[type_id] = mesh
	instance.queue_free()
	return mesh

func get_color_for_type(type_id: String) -> Color:
	var obj_data = _get_object_data(type_id)
	if obj_data.is_empty():
		return Color.WHITE
	var c = obj_data.color
	return Color(c[0], c[1], c[2])

func get_shelf_color() -> Color:
	if current_theme.is_empty():
		return Color(0.6, 0.4, 0.2)
	var c = current_theme.shelf_color
	return Color(c[0], c[1], c[2])

func get_background_color() -> Color:
	if current_theme.is_empty():
		return Color(0.3, 0.3, 0.3)
	var c = current_theme.background_color
	return Color(c[0], c[1], c[2])

func _get_object_data(type_id: String) -> Dictionary:
	for obj in current_theme.objects:
		if obj.type_id == type_id:
			return obj
	return {}
