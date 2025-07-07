extends Control

# Get node obejects
@export_category("OBJETOS")
@onready var play_button: CustomButton = $TextureRect/menu_box/Play
@onready var quit_button: CustomButton = $TextureRect/menu_box/Quit

@export var  pct: float = 0.2

func _on_BotaoJogar_pressed():
	get_tree().change_scene_to_file("res://scenes/lobby/lobby.tscn")

func _on_BotaoSair_pressed():
	get_tree().quit()

func _ready() -> void:
	
	# Settar os botões e suas dimensões
	play_button.update_width_pct(0.3)
	quit_button.update_width_pct(0.1)
	play_button.pressed.connect(_on_BotaoJogar_pressed)
	quit_button.pressed.connect(_on_BotaoSair_pressed)
	
#func _process(delta: float) -> void:
	#pass
	#
#func _physics_process(delta: float) -> void:
	#pass
