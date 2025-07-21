extends Control

func get_drag_data(position: Vector2):
	var data = ""
	
	var preview = self.duplicate()
	
	set_drag_preview(preview)
	
	return data
	
	
