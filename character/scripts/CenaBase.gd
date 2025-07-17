extends Node2D

func _ready():
	if GameState.proxima_entrada.has("position"):
		# Procura o player automaticamente por grupo "character"
		var players = get_tree().get_nodes_in_group("character")
		if players.size() > 0:
			var player = players[0]
			player.global_position = GameState.proxima_entrada["position"]
		else:
			push_warning("Nenhum player encontrado no grupo 'character'.")
