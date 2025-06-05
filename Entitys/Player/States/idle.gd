extends PlayerState

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	player.apply_gravity(_delta)
	player.cam_follow(_delta)
	
	player.velocity.x = lerpf(player.velocity.x, 0, player.deaccel_factor * _delta)
	player.velocity.z = lerpf(player.velocity.z, 0, player.deaccel_factor * _delta)

	var move_direction := player.get_move_direction()

	player.move_and_slide()

	if move_direction != Vector3.ZERO:
		finished.emit("Running")
	if player.jump_just_pressed && player.is_on_floor():
		finished.emit("Jumping")
	if !player.is_on_floor():
		finished.emit("Falling")
	if Input.is_action_just_pressed("slide") and player.get_floor_angle() >= 0.1:
		finished.emit("Sliding")
	
	player.can_throw_n_return_sword(finished)
	

func enter(previous_state_path: String, data := {}) -> void:
	pass

func exit() -> void:
	pass
