extends Node

@onready var timer_label = $CanvasLayer/TimerLabel
@onready var collected_coins_label = $CanvasLayer/CollectedCoinsLabel

@export var time_passed: float = 0.0

var collected : int = 0
var total_collectibles = GlobalSettings.level_size
	
func _on_game_timer_timeout() -> void:
	time_passed += 0.01
	update_timer_display()

func update_timer_display():
	var total_seconds = int(time_passed)
	var minutes = total_seconds / 60
	var seconds = total_seconds % 60
	var hundredths = int((time_passed - total_seconds) * 100)
	
	timer_label.text = "%02d:%02d.%02d" % [minutes, seconds, hundredths]

func _on_player_collectible_collected(new_total: int) -> void:
	collected_coins_label.text = "%d / %d" % [new_total, total_collectibles]
