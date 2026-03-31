extends CharacterBody3D

@export var speed: float = 3.0
var player: Node3D = null

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 9.8 * delta

	if player:
		var look_pos = Vector3(player.global_position.x, global_position.y, player.global_position.z)
		look_at(look_pos, Vector3.UP)

		var direction = (player.global_position - global_position).normalized()
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player = body

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == player:
		player = null
