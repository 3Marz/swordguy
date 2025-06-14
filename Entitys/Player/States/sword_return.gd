extends PlayerState

var move_direction: Vector3 = Vector3.ZERO

func physics_update(delta: float) -> void:
	player.apply_gravity(delta)

	move_direction = player.get_move_direction()
	player.velocity.x = lerpf(player.velocity.x, player.used_speed * move_direction.x, player.air_deaccel_factor * delta)
	player.velocity.z = lerpf(player.velocity.z, player.used_speed * move_direction.z, player.air_deaccel_factor * delta)

	player.move_and_slide()

	if player.jump_just_pressed and player.is_on_floor():
		finished.emit("Jumping")

	player.can_throw_n_return_sword(finished)

	if InputBuffer.is_action_press_buffered("slide") and !Input.is_action_just_pressed("throw"):
		finished.emit("Throwing Sword Down")


func enter(previous_state_path: String, data := {}) -> void:
	$end_timer.start()

func exit():
	pass

func _on_end_timer_timeout() -> void:
	if player.state != player.STATES.Sword_Return:
		return

	if player.is_on_floor():
		if move_direction != Vector3.ZERO:
			finished.emit("Running")
		else:
			finished.emit("Idle")
	else:
		finished.emit("Falling")

