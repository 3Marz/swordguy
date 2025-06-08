extends PlayerState 

var move_direction: Vector3

func physics_update(delta: float) -> void:
	player.apply_gravity(delta)

	move_direction = player.get_move_direction()
	player.velocity.x = lerpf(player.velocity.x, 0, player.sharp_turn_deaccel_factor * delta)
	player.velocity.z = lerpf(player.velocity.z, 0, player.sharp_turn_deaccel_factor * delta)

	player.move_and_slide()


func enter(previous_state_path: String, data := {}) -> void:

	$end_timer.start()
	player.sharp_turn_particle.emitting = true

func exit():
	pass

func _on_end_timer_timeout() -> void:
	if player.is_on_floor():
		if move_direction != Vector3.ZERO:
			finished.emit("Running")
		else:
			finished.emit("Idle")
	else:
		finished.emit("Falling")

