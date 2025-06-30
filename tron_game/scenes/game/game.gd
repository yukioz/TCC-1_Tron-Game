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

@onready var top_wall = $Maplayer/MapArea/Walls/TopWall
@onready var bottom_wall = $Maplayer/MapArea/Walls/BottomWall
@onready var right_wall = $Maplayer/MapArea/Walls/RightWall
@onready var left_wall = $Maplayer/MapArea/Walls/LeftWall

var x_max:float
var x_min:float
var y_max:float
var y_min:float

func _ready() -> void:
	x_max = area_lower_right.global_position.x
	x_min = area_top_left.global_position.x
	y_max = area_lower_right.global_position.y
	y_min = area_top_left.global_position.y
	
	# Configurar mapa
	set_map()
	
	start_round()
	
func set_map():
	x_min = area_top_left.global_position.x
	x_max = area_lower_right.global_position.x
	y_min = area_top_left.global_position.y
	y_max = area_lower_right.global_position.y
	
	var width = x_max - x_min
	var height = y_max - y_min
	var t = 1
	
	# Topo
	setup_wall(top_wall, Vector2(x_min + width / 2, y_min - t / 2), Vector2(width, t))

	# Baixo
	setup_wall(bottom_wall, Vector2(x_min + width / 2, y_max + t / 2), Vector2(width, t))

	# Esquerda
	setup_wall(left_wall, Vector2(x_min - t / 2, y_min + height / 2), Vector2(t, height))

	# Direita
	setup_wall(right_wall, Vector2(x_max + t / 2, y_min + height / 2), Vector2(t, height))
	
func setup_wall(wall_node: Node2D, pos: Vector2, size: Vector2):
	wall_node.global_position = pos
	var shape = wall_node.get_node("CollisionShape2D")
	shape.shape.extents = size / 2
	wall_node.add_to_group("wall")

	var poly = wall_node.get_node("Polygon2D")
	poly.polygon = PackedVector2Array([
		-size / 2,
		Vector2(size.x / 2, -size.y / 2),
		size / 2,
		Vector2(-size.x / 2, size.y / 2),
	])
	poly.color = Color(0.9, 0.9, 0.9)
	
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
	
	for data in GameState.selected_players:
		var player = player_scene.instantiate()
		player.game_scene = self
		player.z_index = 1
		player.position = get_random_position_in_map() # devo usar global_position?
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
	
