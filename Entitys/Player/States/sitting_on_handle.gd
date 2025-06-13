extends PlayerState

var sitting_point: Vector3

func physics_update(delta: float) -> void:

	if sitting_point:
		player.global_position = lerp(player.global_position, sitting_point, delta * player.sitting_on_pole_accel_factor)
	
	var move_direction = player.get_move_direction()
	var look_direction = Vector2(move_direction.z, move_direction.x)
	if look_direction != Vector2.ZERO:
		player.rotation.y = lerp_angle(player.rotation.y, look_direction.angle(), delta * player.sitting_on_model_follow_factor)
	
	if player.jump_just_pressed:
		finished.emit("Jumping")
	

func enter(previous_state_path: String, data := {}) -> void:
	sitting_point = data["sitting_point"]
	
	player.velocity = Vector3.ZERO
	


func exit() -> void:
	pass
