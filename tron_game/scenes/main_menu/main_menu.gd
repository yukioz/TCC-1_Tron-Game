extends Control

# Get node obejects
@export_category("OBJETOS")
@onready var play_button: Button = $TextureRect/Play
@onready var quit_button: Button = $TextureRect/Quit

@export_category("INT")

@export_category("FLOAT")

@export_category("STRING")

@export_category("BOOL")

func _on_BotaoJogar_pressed():
	get_tree().change_scene_to_file("res://scenes/lobby/lobby.tscn")

func _on_BotaoSair_pressed():
	print("saindo...")

func _ready() -> void:
	
	# Settar os botões e suas dimensões
	play_button.custom_minimum_size.x = 500
	play_button.custom_minimum_size.y = 200
	quit_button.custom_minimum_size.x = 300
	quit_button.custom_minimum_size.y = 125
	play_button.pressed.connect(_on_BotaoJogar_pressed)
	quit_button.pressed.connect(_on_BotaoSair_pressed)
	
#func _process(delta: float) -> void:
	#pass
	#
#func _physics_process(delta: float) -> void:
	#pass
