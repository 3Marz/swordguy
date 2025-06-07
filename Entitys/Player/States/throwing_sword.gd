extends PlayerState

var prev_state = ""
var throw_dirction: Vector3
var throw_force: Vector3

@onready var end_timer: Timer = $end_timer
@onready var throw_time: Timer = $throw_time

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	player.cam_follow(delta)

	var look_direction = Vector2(player.get_move_direction().z, player.get_move_direction().x) 
	if look_direction != Vector2.ZERO:
		# player.model.rotation.y = lerp_angle(player.model.rotation.y, look_direction.angle(), _delta * player.model_follow_factor)
		player.rotation.y = lerp_angle(player.rotation.y, look_direction.angle(), delta * player.model_follow_factor)

	var move_direction = player.get_move_direction()
	player.velocity.x = lerpf(player.velocity.x, move_direction.x * player.sword_throw_jump_speed, delta * player.sword_throw_player_deaccel)
	player.velocity.z = lerpf(player.velocity.z, move_direction.z * player.sword_throw_jump_speed, delta * player.sword_throw_player_deaccel)
	player.velocity.y = lerpf(player.velocity.y, 0, delta * player.sword_throw_player_deaccel)

	player.move_and_slide()

func enter(previous_state_path: String, data := {}) -> void:

	player.sword_body.enable_trails()
	player.collision_mask = player.COLLISION_MASK_NO_SWORD

	end_timer.start()
	throw_time.start()
	if previous_state_path != "Idle" and previous_state_path != "Running":
		player.velocity.y = player.sword_throw_jump_boost

	prev_state = previous_state_path

func launch_sword():
	player.throw_count += 1
	player.has_sword = false
	player.sword_body.state_machine._transition_to_next_state("Throw", {})

	# throw_dirction = Vector3.BACK.rotated(Vector3.UP, player.model.rotation.y)
	throw_dirction = Vector3.BACK.rotated(Vector3.UP, player.rotation.y)

	player.sword_body.top_level = true

	player.sword_body.position = player.sword_spwan_pos.global_position 
	player.sword_body.rotation = player.sword_spwan_pos.global_rotation 

	player.sword_body.apply_force(throw_dirction * player.sword_throw_force)
	# player.sword_body.apply_torque(Vector3(0, player.sword_throw_torque_force, 0))

func _on_end_timer_timeout() -> void:
	# player.can_throw_sword = false
	# $throw_cooldown.start()

	match prev_state:
		"Idle":
			finished.emit("Idle")
		"Running":
			finished.emit("Running")
		_:
			finished.emit("Falling")


func exit() -> void:
	pass

func _on_throw_time_timeout() -> void:
	if !player.wall_check_ray.is_colliding():
		launch_sword()
	else:
		end_timer.stop()
		# player.sword_body.disable_trails()
		finished.emit("Sword Reflect")




