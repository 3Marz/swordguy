extends PlayerState

@onready var on_floor_end_timer: Timer = $on_floor_end_timer
@onready var end_flashing_timer: Timer = $end_flashing_timer

func physics_update(delta: float) -> void:
	player.apply_gravity(delta)

	player.velocity.x = lerpf(player.velocity.x, 0, player.hurt_deaccel_factor * delta)
	player.velocity.z = lerpf(player.velocity.z, 0, player.hurt_deaccel_factor * delta)

	player.move_and_slide()

	if player.is_on_floor() and on_floor_end_timer.is_stopped():
		on_floor_end_timer.start()
		

func enter(previous_state_path: String, data := {}) -> void:

	var knockback_direction = Vector3(0, 0.5, -1).rotated(Vector3.UP, player.rotation.y)
	player.velocity = knockback_direction * player.hurt_knockback_strength

	$flash_player.play("flash")
	end_flashing_timer.start()
	player.health.damageable = false
	player.hurt_area.monitoring = false

func _on_on_floor_end_timer_timeout() -> void:
	if player.is_on_floor():
		finished.emit("Idle")

func _on_end_flashing_timer_timeout() -> void:
	$flash_player.play("end")
	player.health.damageable = true
	player.hurt_area.monitoring = true

func exit() -> void:
	pass
