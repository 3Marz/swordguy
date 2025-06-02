extends PlayerState

var ledge_point: Vector3
var wall_normal: Vector3

var ledge_right : Vector3
var ledge_forward: Vector3
var forward_strength: float

var y_model_rotaion: float 

var moving = false

@onready var let_go_timer = $let_go_timer

var moving_platform: MovingPlatform
var old_parent: Node3D

func move_to_ledge_point(use_positon: bool = false):
	moving = true

	var cross = Vector3.UP.cross(wall_normal).normalized()
	y_model_rotaion = atan2(cross.x, cross.z) + PI/2

	player.player_model.position.z = player.model_forward_offset

	if use_positon:
		if !moving_platform:
			# print("AS")
			# if old_parent and old_parent is not MovingPlatform:
			# 	player._reparent(old_parent)
			var tween = get_tree().create_tween()
			tween.tween_property(player, "position", ledge_point, player.time_to_ledge)
			tween.tween_callback(func(): moving = false)
		else:
			player.position = ledge_point
			old_parent = player.get_parent()
			player.rotation.y = y_model_rotaion
			player._reparent(moving_platform)
		player.velocity = Vector3.ZERO
	else:
		player.velocity = (ledge_point - player.global_position).normalized() * player.ledge_speed
		# player.velocity.y = 1
	

func check_ledge_arrival(target_position: Vector3, stopping_distance: float):
	if player.global_position.distance_to(target_position) <= stopping_distance:
		player.velocity = Vector3.ZERO
		moving = false


func calculate_ledge_tangent():
	# Calculate a consistent tangent direction
	ledge_right = Vector3.UP.cross(wall_normal).normalized()
	ledge_forward = ledge_right.cross(Vector3.UP).normalized()
	
	# Ensure the tangent always points in a consistent world direction
	# (e.g., always right when facing the wall)
	if ledge_right.dot(player.global_transform.basis.x) < 0:
		ledge_right = -ledge_right

func test_ledge_ray(ray: RayCast3D):
	ray.force_raycast_update()
	if ray.is_colliding() and ray.get_collision_normal().y > player.min_ledge_angle:

		var vertical_point = ray.get_collision_point()
		player.ledge_ray_horizontal.position.x = ray.position.x
		player.ledge_ray_horizontal.global_position.y = vertical_point.y - 0.01
		player.ledge_ray_horizontal.force_raycast_update()

		if player.ledge_ray_horizontal.is_colliding():
			var ledge_pos = player.ledge_ray_horizontal.get_collision_point() - player.basis.z * player.horizantal_ledge_offset 
			ledge_pos.y = vertical_point.y - player.vertical_ledge_offset

			# moving_platform = null
			# if ray.get_collider() is AnimatableBody3D:
			# 	moving_platform = ray.get_collider()

			ledge_point = ledge_pos
			wall_normal = player.ledge_ray_horizontal.get_collision_normal()

			calculate_ledge_tangent()
			move_to_ledge_point()

func physics_update(delta: float) -> void:
	player.cam_follow(delta)

	var move_direction = -player.get_move_direction() # Get move input direction rotated by camera angle

	# var move_along_ledge = move_direction.signed_angle_to(ledge_right, Vector3.UP)
	forward_strength = move_direction.dot(ledge_forward)
	var right_strength = move_direction.dot(ledge_right)

	if player.debug:
		DebugDraw2D.set_text("forward_strength", str(forward_strength))
		DebugDraw2D.set_text("along_ledge_move_strength", str(right_strength))
		DebugDraw2D.set_text("ledge_right", str(ledge_right))

	player.anim_tree["parameters/Ledge_Hang/blend_position"] = right_strength
	# player.model.rotation.y = lerp_angle(player.model.rotation.y, y_model_rotaion, 10 * delta)
	player.rotation.y = lerp_angle(player.rotation.y, y_model_rotaion, 10 * delta)

	check_ledge_arrival(ledge_point, player.ledge_stopping_distance)

	if !moving:
		if right_strength > player.ledge_move_deadzone: 
			test_ledge_ray(player.ledge_ray_right)
		elif right_strength < -player.ledge_move_deadzone:
			test_ledge_ray(player.ledge_ray_left)

	if moving_platform != null:
		# player.position += moving_platform.velocity
		pass

	player.move_and_slide()

	if forward_strength < -player.ledge_letgo_deadzone and let_go_timer.is_stopped():
		let_go_timer.start()

	if player.jump_just_pressed:
		finished.emit("Jumping")
	if player.is_on_floor():
		finished.emit("Idle")
	
	if Input.is_action_just_pressed("throw"):
		if !player.has_sword:
			player.return_sword()

func enter(previous_state_path: String, data := {}) -> void:
	ledge_point = data['ledge_pos']
	wall_normal = data['wall_normal']
	moving_platform = data['moving_platform']

	calculate_ledge_tangent()
	move_to_ledge_point(true)

func exit() -> void:
	player.player_model.position.z = 0
	if moving_platform and old_parent:
		player._reparent(old_parent)
		# player.model.rotation.y = player.rotation.y
		# player.rotation.y = 0

func _on_let_go_timer_timeout() -> void:
	if forward_strength < -player.ledge_letgo_deadzone:
		finished.emit("Falling")
