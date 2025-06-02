extends PlayerState

func jumpTween():
	var tween = get_tree().create_tween()
	tween.tween_property(player.model, "scale", player.jumpStretchSize, 0.1)
	tween.tween_property(player.model, "scale", Vector3(1,1,1), 0.1)

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	# Maybe not the best solution
	if player.is_on_wall():
		player.floor_block_on_wall = false

	player.cam_follow(delta)
	#player.apply_gravity(delta)
	player.velocity.y -= 22 * delta

	var move_direction = player.get_move_direction()
	player.velocity.x = lerpf(player.velocity.x, player.long_jump_turn_speed*move_direction.x, player.long_jump_air_deaccel_factor * delta)
	player.velocity.z = lerpf(player.velocity.z, player.long_jump_turn_speed*move_direction.z, player.long_jump_air_deaccel_factor * delta)
	
	# player.velocity = Vector3(move_direction.x * player.move_speed, player.velocity.y, move_direction.z * player.move_speed)

	var look_direction = Vector2(player.velocity.z, player.velocity.x)
	if move_direction != Vector3.ZERO:
		# player.model.rotation.y = lerp_angle(player.model.rotation.y, look_direction.angle(), delta * player.model_follow_factor)
		player.rotation.y = lerp_angle(player.rotation.y, look_direction.angle(), delta * player.model_follow_factor)

	player.move_and_slide()


	# TODO better ledge stuff
	if player.velocity.y <= 0:
		player.ledge_ray.force_raycast_update()
		if player.ledge_ray.is_colliding() and player.ledge_ray.get_collision_normal().y > player.min_ledge_angle:

			var vertical_point = player.ledge_ray.get_collision_point()
			player.ledge_ray_horizontal.position.x = player.ledge_ray.position.x
			player.ledge_ray_horizontal.global_position.y = vertical_point.y - 0.01
			player.ledge_ray_horizontal.force_raycast_update()

			if player.ledge_ray_horizontal.is_colliding():
				var ledge_pos = player.ledge_ray_horizontal.get_collision_point() - player.basis.z * player.horizantal_ledge_offset 
				ledge_pos.y = vertical_point.y - player.vertical_ledge_offset

				var moving_platform: MovingPlatform = null
				if player.ledge_ray.get_collider() is AnimatableBody3D:
					moving_platform = player.ledge_ray.get_collider()

				finished.emit("Ledge Grab", {ledge_pos = ledge_pos, 
																			wall_normal = player.ledge_ray_horizontal.get_collision_normal(), 
																			moving_platform = moving_platform})
	
	
	if player.is_on_floor():

		if move_direction != Vector3.ZERO:
			finished.emit("Running")
		else:
			finished.emit("Idle")

	if Input.is_action_just_pressed("throw"):
		if player.has_sword:
			finished.emit("Throwing Sword")
		else:
			player.return_sword()
		


func enter(previous_state_path: String, data := {}) -> void:
	# jumpTween()
	
	var added_velocity : Vector3
	if data:
		if data["added_velo"]:
			added_velocity = data["added_velo"]
	player.velocity += added_velocity
	player.velocity = player.velocity.limit_length(player.max_long_jump_velo_length)
	player.velocity.y = player.long_jump_height
	# player.velocity += player.get_platform_velocity()
	

func exit() -> void:
	player.floor_block_on_wall = true
