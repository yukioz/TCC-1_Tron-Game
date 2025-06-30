extends Area2D

@export var color: Color = Color.WHITE

func _ready():
	queue_redraw()

func _draw():
	draw_circle(Vector2.ZERO, 2.5, color)
