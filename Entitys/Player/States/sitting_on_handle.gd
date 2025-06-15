extends PlayerState

var type: String
var area: Area3D

var move_direction: Vector3
var look_direction: Vector2

func update(delta: float) -> void:
	if area:
		if type == "SwordHandle" and player.sword_body.is_on_moving_platform:
			player.global_position = area.global_position
		else:
			player.global_position = lerp(player.global_position, area.global_position, delta * player.sitting_on_pole_accel_factor)

func physics_update(delta: float) -> void:
	
	# if look_direction != Vector2.ZERO:
	# 	player.rotation.y = lerp_angle(player.rotation.y, look_direction.angle(), delta * player.sitting_on_pole_model_follow_factor)

	move_direction = player.get_move_direction()
	look_direction = Vector2(move_direction.z, move_direction.x)
	
	if player.jump_just_pressed:
		if look_direction != Vector2.ZERO:
			player.rotation.y = look_direction.angle()
		finished.emit("Jumping", {"added_velo": move_direction * player.sitting_on_pole_added_force})
	

func enter(previous_state_path: String, data := {}) -> void:
	type = data["type"]
	area = data["area"]

	move_direction = player.get_move_direction()
	look_direction = Vector2(move_direction.z, move_direction.x)

	# if type == "SwordHandle" and player.sword_body.is_on_moving_platform:
	# 	player.global_position = sitting_point
	# else:
	# 	var tween = get_tree().create_tween()
	# 	tween.tween_property(player, "global_position", sitting_point, player.sitting_on_pole_duration)
	
	player.velocity = Vector3.ZERO

func exit() -> void:
	pass
