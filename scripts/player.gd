extends CharacterBody2D

signal collectible_collected(new_total: int)

var collectibles : int = 0
var checkpoint_position: Vector2 = Vector2.ZERO
var checkpoint_placed: bool = false
var current_checkpoint: Node2D = null

@export var SPEED : int = 50
@export var checkpoint_scene: PackedScene

@onready var player_animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var point_light_2d: PointLight2D = $PointLight2D

func _physics_process(delta: float) -> void:
	var direction_x := Input.get_axis("Move_Left", "Move_Right")
	var direction_y := Input.get_axis("Move_Up", "Move_Down")
	
	if direction_x:
		velocity.x = direction_x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if direction_y:
		velocity.y = direction_y * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
		
	if direction_x > 0:
		player_animated_sprite.flip_h = false
	elif direction_x < 0:
		player_animated_sprite.flip_h = true
		
	if direction_x == 0 and direction_y == 0:
		player_animated_sprite.play("idle")
	else:
		player_animated_sprite.play("walk")
		
	move_and_slide()

func _on_second_pass_timeout() -> void:
	if point_light_2d.texture_scale > 0.25:
		point_light_2d.texture_scale -= 0.016

func add_collectible(amount: int) -> void:
	collectibles += amount
	emit_signal("collectible_collected", collectibles)
	
func place_checkpoint():
	if not checkpoint_placed:
		current_checkpoint = checkpoint_scene.instantiate()
		get_tree().current_scene.add_child(current_checkpoint)
	
	var tile_size = 16
	checkpoint_position = Vector2(
		floor(global_position.x / tile_size) * tile_size + tile_size / 2,
		floor(global_position.y / tile_size) * tile_size + tile_size / 2
	)
	current_checkpoint.global_position = checkpoint_position
	checkpoint_placed = true

func teleport_to_checkpoint():
	if checkpoint_placed:
		global_position = checkpoint_position

func _input(event):
	if event.is_action_pressed("place_checkpoint"):
		place_checkpoint()
	elif event.is_action_pressed("teleport_to_checkpoint"):
		teleport_to_checkpoint()
