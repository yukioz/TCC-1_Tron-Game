# Player.gd
extends Area2D

# dados vindos do Lobby/GameManager
var animal_data: Dictionary
var game_scene
var already_turned = false

# configuração
@export var speed : float = 75
var direction: Vector2
var key_left:  Key
var key_right: Key
var alive := true

# nó Trail
const TrailScene = preload("res://objects/player/trail/trail.tscn")
var trail: Area2D
var last_trail_pos: Vector2

var trail_timer := 0.0
var TRAIL_INTERVAL := 0.01  # gera a cada 10 ms (ajustável)

var trail_disabled := false
var trail_disable_timer := 0.0
const trail_disable_duration := 0.25  # quanto tempo o rastro fica desativado começa em 100%

var rand_chance = 0.01
const rand_chance_max := 0.2
const rand_chance_step := 0.00002


# timer
var disable_timer := 0.0
var time_since_spawn := 0.0
const TRAIL_START_DELAY := 1

# player
@onready var player = $"."
@onready var player_colission : CollisionShape2D = $CollisionShape2D
@onready var SFX_Die : AudioStreamPlayer = $SFX_Die
var can_move = false
var turn_speed : float = 2
var movement = "curve"
var player_radius : float = 2.5
const BASE_RADIUS : float = 2.5
var flying = false

# poderes
var active_powers := {}
const POWER_DURATION := 7.0

signal died(player)

func _ready():
	# parâmetros vindos de animal_data
	key_left = animal_data["keybinds"]["left"]
	key_right = animal_data["keybinds"]["right"]
	
	$Node2D/Polygon2D.polygon = PackedVector2Array([
		Vector2(0, -10),   # ponta de cima
		Vector2(20, 0),    # lateral direita
		Vector2(0, 10),    # ponta de baixo
		Vector2(5, 0),     # dentinho interno
	])
	
	$Node2D/Polygon2D.color = animal_data["color"]

	
	# Random direction
	direction = Vector2.RIGHT.rotated(randf() * TAU)
	rotation = direction.angle()
	
	# Connect signals
	connect("area_entered", Callable(self, "_on_area_entered"))
	
	# espera 3 segundos até ativar
	await get_tree().create_timer(3.0).timeout

func _physics_process(delta):
	if not alive or not can_move:
		return
		
	if can_move and $Node2D/Polygon2D.visible:
		$Node2D/Polygon2D.visible = false
	
	time_since_spawn += delta
	
	# curvatura suave
	if movement == "curve":
		if Input.is_key_pressed(key_left):
			rotation -= turn_speed * delta
		elif Input.is_key_pressed(key_right):
			rotation += turn_speed * delta
	elif movement == "90":
		if Input.is_key_pressed(key_left) and not already_turned:
			rotation -= deg_to_rad(90)
			already_turned = true
		elif Input.is_key_pressed(key_right) and not already_turned:
			rotation += deg_to_rad(90)
			already_turned = true
		elif not Input.is_key_pressed(key_left) and not Input.is_key_pressed(key_right):
			already_turned = false
	# anda pra frente
	var forward = Vector2.RIGHT.rotated(rotation)
	global_position += forward * speed * delta
	global_position = game_scene.wrap_vector(global_position)
	
	# desabilitar/habilitar trail
	if trail_disabled:
		trail_disable_timer += delta
		if trail_disable_timer >= trail_disable_duration:
			trail_disabled = false
			trail_disable_timer = 0.0
			rand_chance = 0.02  # reset após a falha
	else:
		trail_timer += delta
		if trail_timer >= TRAIL_INTERVAL and time_since_spawn > TRAIL_START_DELAY:
			trail_timer = 0.0
			
			if not flying:
				_add_trail_point()

			if randf() < rand_chance:
				trail_disabled = true
				trail_disable_timer = 0.0
				rand_chance = 0.02  # reset após ativar falha
			else:
				rand_chance = min(rand_chance + rand_chance_step, rand_chance_max)

func _add_trail_point():
	trail = TrailScene.instantiate()
	trail.color = animal_data["color"]  # define a cor direto
	trail.radius = player_radius
	trail.creator = self
	var forward = Vector2.RIGHT.rotated(rotation)
	var offset = -forward
	trail.global_position = global_position + offset
	game_scene.map_area.add_child(trail)

func _on_area_entered(area):
	if not alive:
		return
		
	if area.is_in_group("power"):
		var power_name = area.get_scene_file_path().get_file().get_basename()
		apply_power(power_name)
		area.queue_free()
	
	if not flying:
		if area.is_in_group("trail") or  area.is_in_group("wall"):
			alive = false
			SFX_Die.play()
			emit_signal("died", self)
			await SFX_Die.finished
			queue_free()

func apply_power(power_name):
	match power_name:
		"fly_green_power":
			fly_green()
		"move_90_green_power":
			move_in_90_degree()
		"shrink_green_power":
			shrink_green()
		"slow_down_green_power":
			slow_down_green()
		"speed_up_green_power":
			speed_up_green()
		_:
			game_scene.apply_power(power_name, self)

func _draw():
	draw_circle(Vector2.ZERO, player_radius, animal_data["color"])

func confuse_controls():
	var temp = key_left
	key_left = key_right
	key_right = temp
	var remaining = 7
	
	while remaining > 0:
		await get_tree().create_timer(1.0).timeout
		remaining -= 1
	
	key_right = key_left
	key_left = temp

func speed_up_red():
	speed = speed*2
	var remaining = 7
	
	while remaining > 0:
		await get_tree().create_timer(1.0).timeout
		remaining -= 1
	
	speed = speed/2

func slow_down_red():
	speed = speed/2
	turn_speed = turn_speed/2
	var remaining = 7
	
	while remaining > 0:
		await get_tree().create_timer(1.0).timeout
		remaining -= 1
	
	speed = speed*2
	turn_speed = turn_speed*2
	
func speed_up_green():
	speed = speed*2
	turn_speed = turn_speed*2
	var remaining = 7
	
	while remaining > 0:
		await get_tree().create_timer(1.0).timeout
		remaining -= 1
	
	speed = speed/2
	turn_speed = turn_speed/2

func slow_down_green():
	speed = speed/2
	var remaining = 7
	
	while remaining > 0:
		await get_tree().create_timer(1.0).timeout
		remaining -= 1
	
	speed = speed*2
	
func move_in_90_degree():
	movement = "90"
	var remaining = 7
	
	while remaining > 0:
		await get_tree().create_timer(1.0).timeout
		remaining -= 1
	
	movement = "curve"
	
func set_player_radius(r: float, center_offset: Vector2):
	# move o CollisionShape2D
	$CollisionShape2D.position = center_offset
	$CollisionShape2D.shape.radius = r
	queue_redraw()
	
func grow_up_red():
	var forward = Vector2.RIGHT.rotated(rotation).normalized()
	var old_player_radius = player_radius
	player_radius = player_radius * 2
	var off = forward * (player_radius - old_player_radius)
	set_player_radius(player_radius, off)
	TRAIL_INTERVAL *= 2

	await get_tree().create_timer(7.0).timeout

	# 2) volta ao normal (sem offset)
	set_player_radius(player_radius, Vector2.ZERO)
	TRAIL_INTERVAL /= 2
	
func shrink_green():
	player_radius *= 0.5
	queue_redraw()
	player_colission.shape.radius *= 0.5
	TRAIL_INTERVAL *= 0.5
	
	await get_tree().create_timer(7.0).timeout
	
	player_radius *= 2
	queue_redraw()
	await get_tree().create_timer(0.5).timeout
	player_colission.shape.radius *= 2
	TRAIL_INTERVAL *= 2
	
func fly_green():
	flying = true
	var remaining = 7
	
	while remaining > 0:
		await get_tree().create_timer(1.0).timeout
		remaining -= 1
		
	flying = false
	
	
