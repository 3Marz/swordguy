extends PlayerState

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	player.cam_follow(_delta)
	player.velocity.y -= player.wall_slide_gravity * _delta;

	var move_direction = player.get_move_direction()
	player.velocity.x = lerpf(player.velocity.x, 0, player.deaccel_factor)
	player.velocity.z = lerpf(player.velocity.z, 0, player.deaccel_factor)


	# player.velocity.x = lerpf(player.velocity.x, player.max_speed*move_direction.x, player.air_deaccel_factor)
	# player.velocity.z = lerpf(player.velocity.z, player.max_speed*move_direction.z, player.air_deaccel_factor)

	# player.velocity = Vector3(move_direction.x * player.move_speed, player.velocity.y, move_direction.z * player.move_speed)

	var wall_normal = player.get_wall_normal()
	var look_direction = Vector2(wall_normal.z, wall_normal.x)
	# if move_direction != Vector3.ZERO:
	# player.model.rotation.y = lerp_angle(player.model.rotation.y, look_direction.angle(), _delta * 12)


	player.move_and_slide()

	if player.jump_just_pressed:
		finished.emit("Jumping", {"added_velo": player.get_wall_normal()*player.wall_jump_force})
		player.model.rotation.y = look_direction.angle()

	if player.is_on_floor():
		if move_direction != Vector3.ZERO:
			finished.emit("Running")
		else:
			finished.emit("Idle")

func enter(previous_state_path: String, data := {}) -> void:
	player.animation.play("WallSlide")
	player.velocity.y = 0
	var wall_normal = player.get_wall_normal()
	var look_direction = Vector2(wall_normal.z, wall_normal.x)
	player.model.rotation.y = -look_direction.angle()

func exit() -> void:
	pass
