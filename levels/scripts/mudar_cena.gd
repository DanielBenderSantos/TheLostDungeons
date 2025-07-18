extends Area2D

@export var target_scene_path: String
@export var entrada_position: Vector2

func _on_body_entered(body):
	if body.is_in_group("character"):
		GameState.proxima_entrada = {
			"scene": target_scene_path,
			"position": entrada_position
		}
		call_deferred("_trocar_cena")

func _trocar_cena():
	get_tree().change_scene_to_file(target_scene_path)
