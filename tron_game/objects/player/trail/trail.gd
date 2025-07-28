extends Area2D

@export var color: Color = Color.WHITE
@export var radius = 2.5
var creator: Node = null
var active := false
var pause_recovery_frames :=3

func _ready():
	$CollisionShape2D.shape.radius = radius
	queue_redraw()
	# Espera o criador crescer e sair
	await wait_creator_exit()

func _draw():
	draw_circle(Vector2.ZERO, radius, color)
	
	
func _activate_trail():
	add_to_group("trail")
	active = true

func wait_creator_exit():
	await get_tree().process_frame

	while creator != null and get_overlapping_areas().has(creator):
		await get_tree().process_frame
		
	for i in pause_recovery_frames:
		await get_tree().process_frame
		
	
	call_deferred("_activate_trail")
	#add_to_group("trail")
	#active = true
