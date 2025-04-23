extends Control

var animal_data_map := {
	"Porco": {"name": "Porco", "texture": "res://assets/players_sprites/porco.svg", "keybinds": {"left": KEY_LEFT, "right": KEY_RIGHT}},
	"Águia": {"name": "Águia", "texture": "res://assets/players_sprites/aguia.svg", "keybinds": {"left": KEY_Q, "right": KEY_W}},
	"Serpente": {"name": "Serpente", "texture": "res://assets/players_sprites/serpente.svg", "keybinds": {"left": KEY_Z, "right": KEY_X}},
	"Baleia": {"name": "Baleia", "texture": "res://assets/players_sprites/baleia.svg", "keybinds": {"left": KEY_N, "right": KEY_M}},
	"Lobo": {"name": "Lobo", "texture": "res://assets/players_sprites/lobo.svg", "keybinds": {"left": KEY_O, "right": KEY_P}},
	"Dragão": {"name": "Dragão", "texture": "res://assets/players_sprites/dragao.svg", "keybinds": {"left": KEY_G, "right": KEY_H}},
}

var slots := {}

func _ready():
	slots = {
		"Porco": $MarginContainer/GridContainer/PorcoSlot,
		"Águia": $MarginContainer/GridContainer/AguiaSlot,
		"Serpente": $MarginContainer/GridContainer/SerpenteSlot,
		"Baleia": $MarginContainer/GridContainer/BaleiaSlot,
		"Lobo": $MarginContainer/GridContainer/LoboSlot,
		"Dragão": $MarginContainer/GridContainer/DragaoSlot,
	}
	
	for name in animal_data_map.keys():
		_create_add_button(name)

func _create_add_button(animal_name):
	var btn = Button.new()
	btn.text = "Adicionar " + animal_name
	btn.pressed.connect(_on_add_animal.bind(animal_name))
	slots[animal_name].add_child(btn)

func _on_add_animal(animal_name):
	var slot = slots[animal_name]
	slot.get_child(0).queue_free() # Remove o botão

	var box = preload("res://UI/Components/select_player/select_player.tscn").instantiate()
	box.animal_data = animal_data_map[animal_name]
	slot.add_child(box)

	box.connect("tree_exited", func():
		_create_add_button(animal_name)
	)
