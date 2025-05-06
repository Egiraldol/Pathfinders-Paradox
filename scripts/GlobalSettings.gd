extends Node

var level_size: int = 10

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause_menu()

func toggle_pause_menu() -> void:
	if get_tree().paused:
		get_tree().paused = false
	else:
		var pause_menu = preload("res://scenes/pause_menu.tscn").instantiate()
		get_tree().current_scene.add_child(pause_menu)
		get_tree().paused = true
