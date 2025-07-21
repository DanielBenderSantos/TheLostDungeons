extends Node2D

@onready var inventario_ui: CanvasLayer = get_node("cave/mapas/primeiro_andar/InventarioUI")

func _ready():
	inventario_ui.visible = false # começa invisível

func _input(event):
	if event.is_action_pressed("inventory"):
		print("E foi pressionado!")
		inventario_ui.visible = not inventario_ui.visible
