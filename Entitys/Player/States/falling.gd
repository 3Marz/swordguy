extends PlayerState

var can_jump = false
var can_ledge_grab = true

func play_land_tween():
	var tween = get_tree().create_tween()
	tween.tween_property(player.player_model, "scale", player.landStretchSize, 0.1)
	tween.tween_property(player.player_model, "scale", Vector3(1,1,1), 0.1)

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	# Maybe not the best solution
	if player.is_on_wall():
		player.floor_block_on_wall = false

	player.cam_follow(delta)
	player.apply_gravity(delta);

	var move_direction = player.get_move_direction()
	player.velocity.x = lerpf(player.velocity.x, player.used_speed * move_direction.x, player.air_deaccel_factor * delta)
	player.velocity.z = lerpf(player.velocity.z, player.used_speed * move_direction.z, player.air_deaccel_factor * delta)

	# player.velocity = Vector3(move_direction.x * player.move_speed, player.velocity.y, move_direction.z * player.move_speed)

	var look_direction = Vector2(player.velocity.z, player.velocity.x)
	if move_direction != Vector3.ZERO:
		# player.model.rotation.y = lerp_angle(player.model.rotation.y, look_direction.angle(), delta * player.model_follow_factor)
		player.rotation.y = lerp_angle(player.rotation.y, look_direction.angle(), delta * player.model_follow_factor)

	player.move_and_slide()

	# detect ledges
	player.ledge_ray.force_raycast_update()
	if can_ledge_grab and player.ledge_ray.is_colliding() and player.ledge_ray.get_collision_normal().y > player.min_ledge_angle:

		var vertical_point = player.ledge_ray.get_collision_point()
		player.ledge_ray_horizontal.position.x = player.ledge_ray.position.x
		player.ledge_ray_horizontal.global_position.y = vertical_point.y - 0.01
		player.ledge_ray_horizontal.force_raycast_update()
		
		if player.ledge_ray_horizontal.is_colliding():
			var ledge_pos = player.ledge_ray_horizontal.get_collision_point() - player.basis.z * player.horizantal_ledge_offset 
			ledge_pos.y = vertical_point.y - player.vertical_ledge_offset

			# moving plaform
			var moving_platform: MovingPlatform = null
			if player.ledge_ray.get_collider() is AnimatableBody3D:
				moving_platform = player.ledge_ray.get_collider()

			finished.emit("Ledge Grab", {ledge_pos = ledge_pos, 
																		wall_normal = player.ledge_ray_horizontal.get_collision_normal(),
																		moving_platform = moving_platform
																		})
	
	if can_jump and player.jump_just_pressed:
		finished.emit("Jumping")

	if player.is_on_floor():
		play_land_tween()
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
	if data and data["added_velo"]:
		player.velocity += data["added_velo"]

	if previous_state_path == "Running":
		can_jump = true
		$coyote_timer.start()

	if previous_state_path == "Ledge Grab":
		can_ledge_grab = false
		await get_tree().create_timer(0.2).timeout
		can_ledge_grab = true

func exit() -> void:
	player.floor_block_on_wall = true

func _on_coyote_timer_timeout() -> void:
	can_jump = false
