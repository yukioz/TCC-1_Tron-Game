extends CharacterBody2D

# Configurações
@export var color : Color = Color.RED
@export var speed : float = 200.0
@export var trail_width : float = 3.0

# Variáveis
var trail_points := []
var is_alive := true

func _ready():
	# Configura aparência
	$Sprite2D.texture = _create_circle_texture(10, color)  # Tamanho do ponto
	$CollisionShape2D.shape = CircleShape2D.new()
	$CollisionShape2D.shape.radius = 5  # Metade do tamanho do sprite

func _physics_process(delta):
	if !is_alive: return
	
	# Movimentação (você substituirá pelos inputs reais depois)
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()
	
	# Adiciona ponto ao rastro
	_update_trail()

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

func die():
	is_alive = false
	$Sprite2D.modulate.a = 0.3  # Visualização de morte
	set_physics_process(false)

# Função auxiliar para criar o sprite redondo
func _create_circle_texture(size: int, color: Color) -> ImageTexture:
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(color)
	return ImageTexture.create_from_image(image)
