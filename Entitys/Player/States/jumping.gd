extends PlayerState

var reach_max: bool = false

func jumpTween():
	var tween = get_tree().create_tween()
	tween.tween_property(player.player_model, "scale", player.jumpStretchSize, 0.1)
	tween.tween_property(player.player_model, "scale", Vector3(1,1,1), 0.1)

func handle_input(event: InputEvent) -> void:
	if event.is_action_released("jump"):
		player.velocity.y *= player.jump_height_cut
	pass

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	# Maybe not the best solution
	if player.is_on_wall():
		player.floor_block_on_wall = false
	else:
		player.floor_block_on_wall = true

	player.cam_follow(delta)
	player.apply_gravity(delta)
	
	var move_direction = player.get_move_direction()
	player.velocity.x = lerpf(player.velocity.x, player.used_speed * move_direction.x, player.air_deaccel_factor * delta)
	player.velocity.z = lerpf(player.velocity.z, player.used_speed * move_direction.z, player.air_deaccel_factor * delta)

	# player.velocity = Vector3(move_direction.x * player.move_speed, player.velocity.y, move_direction.z * player.move_speed)

	var look_direction = Vector2(player.velocity.z, player.velocity.x)
	if look_direction != Vector2.ZERO:
		# player.model.rotation.y = lerp_angle(player.model.rotation.y, look_direction.angle(), delta * player.model_follow_factor)
		player.rotation.y = lerp_angle(player.rotation.y, look_direction.angle(), delta * player.model_follow_factor)

	player.move_and_slide()

	if player.velocity.y <= 0:
		finished.emit("Falling")

	player.can_throw_n_return_sword(finished)

func enter(previous_state_path: String, data := {}) -> void:
	jumpTween()
	var added_velocity = Vector3.ZERO
	if data:
		if data["added_velo"]:
			added_velocity = data["added_velo"]
	player.velocity.y = player.jump_force
	player.velocity += added_velocity
	# player.velocity += player.get_platform_velocity()

func exit() -> void:
	reach_max = false
	player.floor_block_on_wall = true
