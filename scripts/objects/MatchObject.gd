extends StaticBody3D

var type_id: String = ""
var is_collected: bool = false
var is_blocked: bool = false
var grid_row: int = 0
var grid_col: int = 0
var current_shelf = null

@onready var sprite: Sprite3D = $Sprite3D

func set_texture(texture: Texture2D) -> void:
	sprite.texture = texture

func set_blocked(blocked: bool) -> void:
	is_blocked = blocked
	sprite.modulate.a = 0.35 if blocked else 1.0

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
