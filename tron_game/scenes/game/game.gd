class_name GameScene extends Node2D

# Lista de jogadores com nome, cor e controles

# Armazena os pontos por jogador
var score = {}

# Referência pros jogadores instanciados
var player_nodes = []

# Controle do round
var alive_players = []

@export var player_scene: PackedScene

@onready var map_area = $Maplayer/MapArea
@onready var area_top_left = $Maplayer/UpperLeft
@onready var area_lower_right = $Maplayer/LowerRight

var x_max:float
var x_min:float
var y_max:float
var y_min:float

func _ready() -> void:
	x_max = area_lower_right.position.x
	x_min = area_top_left.position.x
	y_max = area_lower_right.position.y
	y_min = area_top_left.position.y
	
	# Area do Mapa
	print("leopa")
	
	start_round()
	
func wrap_vector(v:Vector2) -> Vector2:
	
	if v.x > x_max:
		return Vector2(x_min, v.y)
	elif v.x < x_min:
		return Vector2(x_max, v.y)
	elif v.y > y_max:
		return Vector2(v.y, y_min)
	elif v.y < y_min:
		return Vector2(v.x, y_max)
		
	return v
	
func get_random_position_in_map() -> Vector2:
	
	return Vector2(
		randf_range(x_min+50, x_max-50),
		randf_range(y_min+50, y_max-50)
	)
	
func clear_map():
	for player in player_nodes:
		player.queue_free()
		
	player_nodes.clear()
	
func start_round():
	clear_map()
	alive_players.clear()
	
	print(GameState.selected_players)
	
	for data in GameState.selected_players:
		var player = player_scene.instantiate()
		player.position = get_random_position_in_map()
		player.animal_data = data
		player_nodes.append(player)
		alive_players.append(player)
		player.connect("died", Callable(self, "_on_player_died"))
		map_area.add_child(player)
		print("adicionei")
		
func _on_player_died(player):
	alive_players.erase(player)
	
	if alive_players.size() == 1:
		end_round()
		
func end_round():
	print("Fim do round!")
	
