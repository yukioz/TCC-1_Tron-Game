extends Node

@export_category("Variaveis do tipo String")
@export var saudacao: String = "olá mundo!"

@export_category("variáveis do tipo inteiro")
@export var num_a: int = 2
@export var num_b: int = 3

@export_category("variáveis do tipo float")
@export var num_af: float = 2.5
@export var num_bf: float = 10.5

@export_category("variáveis do tipo bool")
@export var num_ab: bool = true
@export var num_bb: bool = false

func ola_mundo():
	print(saudacao)

func _ready() -> void:
	ola_mundo()
	
func _process(delta: float) -> void:
	print(Input.is_action_just_pressed("atacar"))
	print(delta)
	pass
	
func _physics_process(delta: float) -> void:
	pass
