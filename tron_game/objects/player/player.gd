# Player.gd
extends CharacterBody2D

# dados vindos do Lobby/GameManager
var animal_data: Dictionary

# configuração
@export var speed := 200
var key_left:  int
var key_right: int
var alive := true

# nó Trail
const TrailScene = preload("res://objects/player/trail/trail.tscn")
var trail: Line2D

signal died(player)

func _ready():
	# parâmetros vindos de animal_data
	key_left  = animal_data["keybinds"]["left"]
	key_right = animal_data["keybinds"]["right"]
	# instancia e configura o trail
	trail = TrailScene.instantiate()
	trail.default_color = animal_data["color"]
	get_parent().add_child(trail)
	trail.global_position = global_position
	trail.clear_points()
	trail.width = 4
	trail.add_to_group("trail")
	# espera 3 segundos até ativar
	await get_tree().create_timer(3.0).timeout

func _physics_process(delta):
	if not alive:
		return
	# curvatura suave
	if Input.is_key_pressed(key_left):
		rotation -= 2 * delta
	elif Input.is_key_pressed(key_right):
		rotation += 2 * delta
	# anda pra frente
	velocity = Vector2(speed, 0).rotated(rotation)
	move_and_collide(velocity * delta)
	# atualiza rastro
	trail.add_point(global_position)
	
func _on_body_entered(body):
	if not alive:
		return
	if body.is_in_group("wall") or body.is_in_group("trail"):
		alive = false
		emit_signal("died", self)
		queue_free()
