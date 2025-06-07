extends PlayerState

func physics_update(delta: float) -> void:
	player.apply_gravity(delta)
	player.move_and_slide()

func enter(previous_state_path: String, data := {}) -> void:
	
	var knockback_direction = Vector3(0, 0.5, -1).rotated(Vector3.UP, player.rotation.y)
	player.velocity = knockback_direction * player.reflect_knockback

	$end_timer.start()

func exit() -> void:
	player.sword_body.disable_trails()

func _on_end_timer_timeout() -> void:
	if player.is_on_floor():
		if player.get_move_direction() != Vector3.ZERO:
			finished.emit("Running")
		else:
			finished.emit("Idle")
	else:
		finished.emit("Falling")

