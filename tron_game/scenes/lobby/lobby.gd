extends Control

var animal_data_map = GameState.animal_data_map

var animal_to_play : = []

var slots := {}

@onready var gridContainer: GridContainer = $Panel/MarginContainer/VBoxContainer/GridContainer

func _ready():
	var vp = get_viewport().get_visible_rect().size
	gridContainer.size = Vector2((vp.x * 0.8), (vp.y * 0.8))
	
	slots = {
		"Porco": $Panel/MarginContainer/VBoxContainer/GridContainer/HBoxContainer/PorcoSlot,
		"Águia": $Panel/MarginContainer/VBoxContainer/GridContainer/HBoxContainer/AguiaSlot,
		"Serpente": $Panel/MarginContainer/VBoxContainer/GridContainer/HBoxContainer/SerpenteSlot,
		"Baleia": $Panel/MarginContainer/VBoxContainer/GridContainer/HBoxContainer2/BaleiaSlot,
		"Lobo": $Panel/MarginContainer/VBoxContainer/GridContainer/HBoxContainer2/LoboSlot,
		"Dragão": $Panel/MarginContainer/VBoxContainer/GridContainer/HBoxContainer2/DragaoSlot,
	}
	
	for animal_name in animal_data_map.keys():
		call_deferred_thread_group("_create_add_button", animal_name) #  _create_add_button(name)

func _create_add_button(animal_name):
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(200, 50)
	btn.text = "Adicionar " + animal_name
	btn.pressed.connect(_on_add_animal.bind(animal_name))
	slots[animal_name].call_deferred("add_child", btn)

func _on_add_animal(animal_name):
	var slot = slots[animal_name]
	slot.get_child(0).queue_free() # Remove o botão

	var box = preload("res://UI/Components/select_player/select_player.tscn").instantiate()
	box.animal_data = animal_data_map[animal_name]
	slot.call_deferred("add_child", box) 
	
	animal_to_play.append(animal_data_map[animal_name])

	box.connect("tree_exited", func():
		_create_add_button(animal_name)
		animal_to_play.erase(animal_data_map[animal_name])
	)

func _on_button_pressed() -> void:
	
	if animal_to_play.size() >= 2:
		print("ok")
	else:
		print("Pelo menos dois jogadores devem ser adicionados!")
		return
	
	# Guarda info do jogadores em singleton
	GameState.selected_players = animal_to_play.duplicate(true)
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")


func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
