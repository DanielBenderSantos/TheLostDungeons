extends Area2D

@export var target_scene_path: String

func _on_body_entered(body):
	if body.is_in_group("character"):
		call_deferred("_trocar_cena")

func _trocar_cena():
	get_tree().change_scene_to_file(target_scene_path)
