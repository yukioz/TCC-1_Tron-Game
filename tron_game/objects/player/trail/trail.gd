extends Area2D

@export var color: Color = Color.WHITE
@export var radius = 2.5
var creator: Node = null
var active := false

func _ready():
	$CollisionShape2D.shape.radius = radius
	queue_redraw()
	# Espera o criador crescer e sair
	await wait_creator_exit()

func _draw():
	draw_circle(Vector2.ZERO, radius, color)

func wait_creator_exit():
	#await get_tree().create_timer(0.1).timeout  # tempo mínimo pro player crescer

	while creator != null and get_overlapping_areas().has(creator):
		await get_tree().process_frame
		
	await get_tree().create_timer(0.1).timeout

	add_to_group("trail")
	active = true
