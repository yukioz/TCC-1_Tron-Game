# Player.gd
extends Area2D

# dados vindos do Lobby/GameManager
var animal_data: Dictionary
var game_scene

# configuração
@export var speed := 100
var direction: Vector2
var key_left:  int
var key_right: int
var alive := true

# nó Trail
const TrailScene = preload("res://objects/player/trail/trail.tscn")
var trail: Area2D
var last_trail_pos: Vector2

var trail_timer := 0.0
const TRAIL_INTERVAL := 0.02  # gera a cada 20 ms (ajustável)

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

# poderes
var active_powers := {}
const POWER_DURATION := 7.0

signal died(player)

func _ready():
	# parâmetros vindos de animal_data
	key_left  = animal_data["keybinds"]["left"]
	key_right = animal_data["keybinds"]["right"]
	
	# Random direction
	direction = Vector2.RIGHT.rotated(randf() * TAU)
	
	# Connect signals
	connect("area_entered", Callable(self, "_on_area_entered"))
	
	# espera 3 segundos até ativar
	await get_tree().create_timer(3.0).timeout

func _physics_process(delta):
	if not alive:
		return
		
	time_since_spawn += delta
	
	# curvatura suave
	if Input.is_key_pressed(key_left):
		rotation -= 2 * delta
	elif Input.is_key_pressed(key_right):
		rotation += 2 * delta
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
			_add_trail_point()

			if randf() < rand_chance:
				trail_disabled = true
				trail_disable_timer = 0.0
				rand_chance = 0.02  # reset após ativar falha
			else:
				rand_chance = min(rand_chance + rand_chance_step, rand_chance_max)

	
func _add_trail_point():
	var trail = TrailScene.instantiate()
	print("Player pos:", global_position)
	print("Player parent:", get_parent().name)
	trail.color = animal_data["color"]  # define a cor direto
	trail.add_to_group("trail")
	game_scene.map_area.add_child(trail)
	var forward = Vector2.RIGHT.rotated(rotation)
	var offset = -forward * 7.0
	trail.global_position = global_position + offset
	
func _on_area_entered(area):
	if not alive:
		return
		
	print("COLIDIU COM:", area.name, " - grupos:", area.get_groups())
	
	if area.is_in_group("wall") or area.is_in_group("trail"):
		alive = false
		emit_signal("died", self)
		queue_free()
		
func _draw():
	draw_circle(Vector2.ZERO, 2.5, animal_data["color"])
