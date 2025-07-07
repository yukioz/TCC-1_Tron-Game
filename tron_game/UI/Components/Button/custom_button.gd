extends Button
class_name CustomButton

@export var width_pct: float = 0.1
@export var min_width: float = 200
@export var min_height: float = 100

func update_width_pct(new_pct: float) -> void:
	width_pct = new_pct
	_update_size()

func _ready() -> void:
	connect("pressed", Callable(self, "_on_pressed"))
	get_viewport().connect("size_changed", Callable(self, "_update_size"))
	_update_size()

func _update_size() -> void:
	var vp = get_viewport().get_visible_rect().size
	var w = max(vp.x * width_pct, min_width)
	var h = max(w * 0.5, min_height)
	var new_size = Vector2(w, h)
	custom_minimum_size = new_size
	set_deferred("custom_minimum_size", new_size)
	set_deferred("size", new_size)
	set_deferred("position", (vp - new_size) * 0.5)

func _on_pressed() -> void:
	print("clicou!")
