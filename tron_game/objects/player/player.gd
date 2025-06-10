extends CharacterBody2D

# Configurações
@export var color : Color = Color.RED
@export var speed : float = 200.0
var key_left := KEY_LEFT
var key_left := KEY_RIGHT
#@export var trail_width : float = 3.0

# Variáveis
var trail_points := []
var is_alive := true

var active := false
signal died(player)

func _ready():
	# Recebe dados
	key_left   = animal_data["keybinds"]["left"]
	key_right  = animal_data["keybinds"]["right"]
	color      = animal_data["color"]
	
	# Configura aparência
	var trail = $Line2D
	trail.clear_points()
	trail.width = 5
	trail.default_color = color
	trail.add_to_group("trail")
	
	$CollisionShape2D.shape.radius = 5

func _physics_process(delta):
	if !is_alive: return
	
	if Input.is_key_pressed(key_left):
		rotation -= 2*delta
	elif  Input.is_key_pressed(key_right):
		rotation += 2*delta
		
	velocity = Vector2(speed, 0).rotated(rotation)
	move_and_collide(velocity*delta)
	
	$Line2D.add_point(global_position)
	update()
	
func _draw():
	draw_circle(Vector2.ZERO, 5, color)

func _update_trail():
	trail_points.append(position)
	
	# Cria/atualiza o Line2D do rastro
	if !has_node("Trail"):
		var trail = Line2D.new()
		trail.width = trail_width
		trail.default_color = color
		trail.name = "Trail"
		add_child(trail)
	
	$Trail.points = trail_points

func _collide(body):
	if body.is
	

# Função auxiliar para criar o sprite redondo
func _create_circle_texture(size: int, color: Color) -> ImageTexture:
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(color)
	return ImageTexture.create_from_image(image)
