extends CharacterBody2D

const SPEED : int = 50.0

var current_direction = Vector2.RIGHT

func _physics_process(delta: float) -> void:
	follow_right_wall()
	move_and_slide()

func follow_right_wall() -> void:
	move_in_direction(current_direction)

func move_in_direction(direction: Vector2) -> void:
	velocity = direction * SPEED

func _on_timer_timeout() -> void:
	pass # Replace with function body.
