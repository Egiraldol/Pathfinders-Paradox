extends Area2D

var total_collectibles = GlobalSettings.level_size

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		get_tree().paused = true
		
		var win_popup = preload("res://scenes/win_popup.tscn").instantiate()
		
		get_tree().current_scene.add_child(win_popup)
