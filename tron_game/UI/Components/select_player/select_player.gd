extends Control

signal key_chosen(keycode)
# Configuração por animal
@export var animal_data := {
	"name": "Porco",
	"texture": "res://assets/players_sprites/porco.svg",
	"keybinds": {"left": KEY_LEFT, "right": KEY_RIGHT}
}

@onready var VBox: VBoxContainer = $VBoxContainer
@onready var Header: PanelContainer = $VBoxContainer/Header
@onready var Body: PanelContainer = $VBoxContainer/Body
@onready var Footer: PanelContainer = $VBoxContainer/Footer
@onready var Body_margin: MarginContainer = $VBoxContainer/Body/VBoxContainer/PanelContainer/MarginContainer
@onready var Header_margin: MarginContainer = $VBoxContainer/Header/MarginContainer
@onready var control: Control = $"."

func _ready():
	# Aplica os dados do animal
	$VBoxContainer/Body/VBoxContainer/Label.text = animal_data["name"]
	$VBoxContainer/Body/VBoxContainer/PanelContainer/MarginContainer/textureRect.texture = load(animal_data["texture"])

	# Configura botões de keybind
	$VBoxContainer/Footer/MarginContainer/HBoxContainer/key_left.text = OS.get_keycode_string(animal_data["keybinds"]["left"])
	$VBoxContainer/Footer/MarginContainer/HBoxContainer/key_right.text = OS.get_keycode_string(animal_data["keybinds"]["right"])
	
	get_viewport().connect("size_changed", Callable(self, "_update_size"))
	_update_size()
	
func _update_size() -> void:
	var vp = get_viewport().get_visible_rect().size
	
	Body_margin.add_theme_constant_override("margin_top", 10)
	Body_margin.add_theme_constant_override("margin_bottom", 10)
	Body_margin.add_theme_constant_override("margin_left", 10)
	Body_margin.add_theme_constant_override("margin_right", 10)
	
	Header_margin.add_theme_constant_override("margin_top", 10)
	Header_margin.add_theme_constant_override("margin_bottom", 10)
	Header_margin.add_theme_constant_override("margin_left", 10)
	Header_margin.add_theme_constant_override("margin_right", 10)
	

func _on_key_left_pressed():
	var new_key = await wait_for_key_input()
	animal_data["keybinds"]["left"] = new_key
	$VBoxContainer/Footer/MarginContainer/HBoxContainer/key_left.text = OS.get_keycode_string(new_key)

func _on_key_right_pressed():
	var new_key = await wait_for_key_input()
	animal_data["keybinds"]["right"] = new_key
	$VBoxContainer/Footer/MarginContainer/HBoxContainer/key_right.text = OS.get_keycode_string(new_key)

func wait_for_key_input():
	set_process_input(true)
	var keycode = await self.key_chosen
	return keycode
	
func _input(event):
	if event is InputEventKey and event.pressed:
		emit_signal("key_chosen", event.keycode)
		set_process_input(false)


func _on_close_animal_pressed() -> void:
	queue_free()
