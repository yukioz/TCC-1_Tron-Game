class_name GameScene extends Node2D

# Lista de jogadores com nome, cor e controles

# Armazena os pontos por jogador

# Referência pros jogadores instanciados
var player_nodes :  = []

# Controle do round
var alive_players = []

var players_rank := []  # ordem de morte no round atual
var last_player
var is_round_ending = false


# Poderes
var powers = {
	"green_speed_up": "res://objects/powers/greenPowers/speed_up_green_power.tscn",
	"green_slow_down": "res://objects/powers/greenPowers/slow_down_green_power.tscn",
	"green_fly": "res://objects/powers/greenPowers/fly_green_power.tscn",
	#"green_shrink": "res://objects/powers/greenPowers/shrink_green_power.tscn", # Bug
	"green_move_90": "res://objects/powers/greenPowers/move_90_green_power.tscn",
	"red_confuse": "res://objects/powers/redPowers/confuse_red_power.tscn",
	#"red_grow_up": "res://objects/powers/redPowers/grow_red_power.tscn", #Bug
	"red_slow_down": "res://objects/powers/redPowers/slow_down_red_power.tscn",
	"red_speed_up": "res://objects/powers/redPowers/speed_up_red_power.tscn",
	"clear_map": "res://objects/powers/bluePowers/clear_map_power.tscn",
	"open_borders": "res://objects/powers/bluePowers/open_borders_power.tscn"
}
var time_passed := 0.0
var next_power_time := randf_range(5.0, 10.0)
var borders_open = false

@onready var round_countdown = $Maplayer/Label
@onready var score_vbox : VBoxContainer = $CanvasLayer/MarginContainer/VBoxContainer/ScorePanel/VBoxContainer
@onready var pause_menu : = $PauseMenu/CenterContainer
@onready var winning_player_label : Label = $WinningPanel/CenterContainer/PanelContainer/VBoxContainer/Label
@onready var winner_menu : = $WinningPanel/CenterContainer

@export var player_scene: PackedScene

@onready var map_area = $Maplayer
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

func update_score_ui():
	
	for child in score_vbox.get_children():
		child.queue_free()
	
	for data in GameState.selected_players:
		var score_name = data["name"]
		var pts = GameState.scores.get(score_name, 0)
		var lbl = Label.new()
		lbl.text = "%s  %d" % [score_name, pts]
		score_vbox.add_child(lbl)


func apply_power(power_name, source_player):
	match power_name:
		"confuse_red_power":
			for player in player_nodes:
				if player.name != source_player.name:
					player.confuse_controls()
		"grow_red_power":
			for player in player_nodes:
				if player.name != source_player.name:
					player.grow_up_red()
		"slow_down_red_power":
			for player in player_nodes:
				if player.name != source_player.name:
					player.slow_down_red()
		"speed_up_red_power":
			for player in player_nodes:
				if player.name != source_player.name:
					player.speed_up_red()
		"clear_map_power":
			for child in map_area.get_children():
				if child.is_in_group("trail"):
					child.queue_free()
		"open_borders_power":
			top_wall.remove_from_group("wall")
			top_wall.get_node("Polygon2D").color = Color("#023E8A")
			bottom_wall.remove_from_group("wall")
			bottom_wall.get_node("Polygon2D").color = Color("#023E8A")
			right_wall.remove_from_group("wall")
			right_wall.get_node("Polygon2D").color = Color("#023E8A")
			left_wall.remove_from_group("wall")
			left_wall.get_node("Polygon2D").color = Color("#023E8A")
			
			var remaining = 7
	
			while remaining > 0:
				await get_tree().create_timer(1.0).timeout
				remaining -= 1
			
			top_wall.add_to_group("wall")
			top_wall.get_node("Polygon2D").color = Color("#FFFFFF")
			bottom_wall.add_to_group("wall")
			bottom_wall.get_node("Polygon2D").color = Color("#FFFFFF")
			right_wall.add_to_group("wall")
			right_wall.get_node("Polygon2D").color = Color("#FFFFFF")
			left_wall.add_to_group("wall")
			left_wall.get_node("Polygon2D").color = Color("#FFFFFF")

func _ready() -> void:
	score_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	update_score_ui()
	
	await get_tree().process_frame
	
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
	var t : float = 1
	
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
	
	var random_position = Vector2(
		randf_range(x_min+100, x_max-100),
		randf_range(y_min+100, y_max-100)
	)
	
	return random_position
	
func clear_map():
		
	player_nodes.clear()
	
	await get_tree().process_frame  # <- Espera os players sumirem
		
	for child in map_area.get_children():
		if child.is_in_group("trail") or child.is_in_group("power"):
			child.queue_free()
		
	
func show_countdown():
	round_countdown.visible = true
	for i in [3, 2, 1]:
		round_countdown.text = str(i)
		await get_tree().create_timer(1).timeout
	round_countdown.text = "Go!"
	await get_tree().create_timer(1).timeout
	round_countdown.visible = false
	
func start_round():
	
	await get_tree().create_timer(1).timeout
	
	is_round_ending = false
	clear_map()
	alive_players.clear()
	
	for data in GameState.selected_players:
		var player = player_scene.instantiate()
		player.game_scene = self
		player.z_index = 1
		player.global_position = get_random_position_in_map() # devo usar global_position?
		player.animal_data = data
		player_nodes.append(player)
		alive_players.append(player)
		player.connect("died", Callable(self, "_on_player_died"))
		map_area.call_deferred("add_child", player)
		
	await show_countdown()
	
	for player in player_nodes:
		player.can_move = true
			
		
func _on_player_died(player):
	if is_round_ending:
		return
	
	players_rank.append(player.animal_data["name"])
	
	alive_players.erase(player)
	player_nodes.erase(player)
	
	if alive_players.size() == 1 and not is_round_ending:
		is_round_ending = true
		
		last_player = alive_players[0]
		players_rank.append(last_player.animal_data["name"])
		
		await get_tree().create_timer(3.0).timeout
		
		if is_instance_valid(last_player) and not last_player.is_queued_for_deletion():
			last_player.queue_free()
			alive_players.erase(last_player)
			player_nodes.erase(last_player)
		
		end_round()
		
func end_round():
	
	clear_map()
	
	for i in range(players_rank.size()):
		var animal_name = players_rank[i]
		if not GameState.scores.has(animal_name):
			GameState.scores[animal_name] = 0
		GameState.scores[animal_name] += i
		
		update_score_ui()
		
		if GameState.scores[animal_name] >= 1:
			game_end(animal_name)
			return
	
	players_rank.clear()
	start_round()
	
func game_end(winner_name: String):
	winning_player_label.text = winner_name + " ganhou! 👑"
	
	get_tree().paused = true
	winner_menu.visible = true
	
	
func spawn_random_power():
	var keys = powers.keys()
	var random_key = keys[randi() % keys.size()]
	var power_path = powers[random_key]
	
	var power_scene = load(power_path)
	var power = power_scene.instantiate()
	power.add_to_group("power")
	power.global_position = get_random_position_in_map()
	
	map_area.add_child(power)
	
	
func _physics_process(delta: float) -> void:
	if borders_open:
		for wall in [top_wall, bottom_wall, left_wall, right_wall]:
			wall.visible = false
			wall.get_node("CollisionShape2D").disabled = true
	else:
		for wall in [top_wall, bottom_wall, left_wall, right_wall]:
			wall.visible = true
			wall.get_node("CollisionShape2D").disabled = false
			
	time_passed += delta

	if time_passed >= next_power_time:
		spawn_random_power()
		time_passed = 0.0
		next_power_time = randf_range(5.0, 10.0)


func _on_pause_pressed() -> void:
	# ativa o pause e mostra o menu
	get_tree().paused = true
	pause_menu.visible = true


func _on_continue_pressed() -> void:
	pause_menu.visible = false
	get_tree().paused = false


func _on_go_to_menu_pressed() -> void:
	# retorna ao menu principal
	get_tree().paused = false
	GameState.scores.clear()
	players_rank.clear()
	is_round_ending = false
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")


func _on_return_to_lobby_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/lobby/lobby.tscn")
