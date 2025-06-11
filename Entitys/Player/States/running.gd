extends PlayerState

var curve_offset = Vector3.ZERO
var prev_state = ""

var is_moving_downward_on_slope = false
var used_speed = 0 

var look_direction = Vector2.ZERO

var prev_move_direction = Vector3.ZERO

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	player.apply_gravity(_delta)
	player.cam_follow(_delta)

	var move_direction : Vector3 = player.get_move_direction();
	prev_move_direction = move_direction

	if move_direction.x:
		curve_offset.x += player.curve_sample_rate
	if move_direction.z:
		curve_offset.z += player.curve_sample_rate

	# for speed downslops
	if player.get_floor_angle() > player.min_slop_angle and player.get_last_motion().y < 0:
		used_speed = lerpf(used_speed, player.max_fast_speed, 0.2)
		player.particle_trail.speed_scale = 1.5
	else:
		used_speed = lerpf(used_speed, player.max_speed, 0.2)
		player.particle_trail.speed_scale = 1

	player.velocity.x = lerpf(player.velocity.x, player.accelcurve.sample(curve_offset.x) * player.used_speed * move_direction.x, player.accel_factor * _delta)
	player.velocity.z = lerpf(player.velocity.z, player.accelcurve.sample(curve_offset.z) * player.used_speed * move_direction.z, player.accel_factor * _delta)

	# player.velocity = Vector3(move_direction.x * player.move_speed, player.velocity.y, move_direction.z * player.move_speed)

	look_direction = Vector2(player.velocity.z, player.velocity.x)
	# player.model.rotation.y = lerp_angle(player.model.rotation.y, look_direction.angle(), _delta * 12)
	player.rotation.y = lerp_angle(player.rotation.y, look_direction.angle(), _delta * 12)

	player.model.rotation.z = lerpf(player.model.rotation.z, player.delta_rotation * player.model_tilt_multiplier, _delta * player.model_tilt_speed)
	player.model.rotation_degrees.z = clamp(player.model.rotation_degrees.z, -player.max_tilt_angle, player.max_tilt_angle)

	player.move_and_slide()

	if move_direction == Vector3.ZERO:
		finished.emit("Idle")

	if player.jump_just_pressed && player.is_on_floor():
		finished.emit("Jumping")

	if !player.is_on_floor():
		finished.emit("Falling")

	if Input.is_action_pressed("slide") and !player.jump_just_pressed:
		finished.emit("Sliding") 

	var velocity2 = Vector2(player.velocity.x, player.velocity.z).length()
	if move_direction.dot(prev_move_direction) < player.sharp_turn_deadzone and velocity2 > player.sharp_turn_min_velo_length:
		finished.emit("Sharp Turn")

	player.can_throw_n_return_sword(finished)
	

func enter(previous_state_path: String, data := {}) -> void:
	if player.velocity.length() > 8:
		player.used_speed = player.max_fast_speed

	# print(player.velocity.length())
	player.particle_trail.emitting = true
	prev_state = previous_state_path
	if previous_state_path == "Idle":
		curve_offset = Vector3.ZERO

func exit() -> void:
	player.particle_trail.emitting = false
	player.particle_trail.speed_scale = 1

	if !player.is_on_wall() and player.velocity != Vector3.ZERO:
		player.rotation.y = Vector2(player.velocity.z, player.velocity.x).angle()
	var tween = get_tree().create_tween()
	# tween.tween_property(player, "rotation", Vector3(0, Vector2(player.velocity.z, player.velocity.x).angle(), 0), 0.1)
	# tween.tween_property(player.model, "rotation", Vector3(player.model.rotation.x, player.model.rotation.y, 0), 0.1)
	tween.tween_property(player.model, "rotation", Vector3(player.model.rotation.x, 0, 0), 0.1)




