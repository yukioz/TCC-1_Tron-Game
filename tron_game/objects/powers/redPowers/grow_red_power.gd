extends Area2D

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.apply_power(get_scene_file_path().get_file().get_basename())
		queue_free()
