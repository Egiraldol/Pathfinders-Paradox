extends Area2D

@export var value : int = 1

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if body.has_method("add_collectible"):
			body.add_collectible(value)
		queue_free()
