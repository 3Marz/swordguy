extends PlayerState

@onready var slide_end_timer: Timer = $slide_end_timer
@onready var let_go_timer: Timer = $let_go_sliding

var downhill_multiplier : float = 0.4
var move_direction: Vector3

var can_jump = true
var off_ground = false
var is_falling = false 

var sliding_loop_time_scale = "parameters/Sliding/Slide Loop/TimeScale/scale"


func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	player.cam_follow(delta)
	player.apply_gravity(delta)
	
	move_direction = player.get_move_direction()
	player.velocity.x = lerpf(player.velocity.x, player.slide_move_speed * move_direction.x, player.slide_deaccel)
	player.velocity.z = lerpf(player.velocity.z, player.slide_move_speed * move_direction.z, player.slide_deaccel)
	
	# deaccel
	player.velocity = lerp(player.velocity, Vector3.ZERO, player.slide_deaccel)
	
	var collided := player.move_and_slide()
	if collided:
		var slide_normal = player.get_floor_normal()
		var last_y_motion = player.get_last_motion().y
		
		if last_y_motion < 0:
			downhill_multiplier += player.downhill_multiplier_step
		elif last_y_motion > 0:
			downhill_multiplier -= player.downhill_multiplier_step
		
		downhill_multiplier = clampf(downhill_multiplier, 0.4, 1.0)
		
		player.velocity.x += slide_normal.x * downhill_multiplier
		player.velocity.z += slide_normal.z * downhill_multiplier
		player.velocity.y -= slide_normal.y
		#player.velocity = clamp(player.velocity, -player.max_slop_velocity, player.max_slop_velocity)
		player.velocity = player.velocity.limit_length(player.max_slop_velo_length)
		
		player.model.rotation.x = lerpf(player.model.rotation.x, -player.get_floor_angle() if last_y_motion > 0 else player.get_floor_angle(), delta * 10)
		#player.model.rotation.x = lerpf(player.model.rotation.x, player.velocity.angle_to(player.velocity*2), _delta * 10)
	
	var look_direction = Vector2(player.velocity.z, player.velocity.x)
	if look_direction.length() != 0:
		# player.model.rotation.y = lerp_angle(player.model.rotation.y, look_direction.angle(), _delta * 10)
		player.rotation.y = lerp_angle(player.rotation.y, look_direction.angle(), delta * 10)
	
	var strafe_direction = Input.get_axis("move_left", "move_right") / 4
	player.model.rotation.z = lerpf(player.model.rotation.z, strafe_direction, delta * 2)
	# player.skeleton.set_bone_pose_rotation(player.skeleton.find_bone("Torso"), )

	var loop_time_scale = Utils.remap_range(0, 10, 0, 1, player.velocity.length())
	player.anim_tree[sliding_loop_time_scale] = loop_time_scale
	
	if player.is_on_floor():
		$coyote_timer.stop()
		can_jump = true
		off_ground = false
	elif !player.is_on_floor() and !off_ground:
		off_ground = true
		$coyote_timer.start()
	
	if player.velocity.length() < player.min_slide_velocity and slide_end_timer.time_left == 0:
		slide_end_timer.start()
	if can_jump and player.jump_just_pressed:
		if player.velocity.length() >= player.slide_velocity_for_longjump:
			finished.emit("Long Jump")
		else:
			finished.emit("Jumping")
	
	is_falling = player.get_last_motion().y < 0 and !player.is_on_floor()
	if is_falling and move_direction.length() != 0 and let_go_timer.is_stopped():
		let_go_timer.start()

func _on_slide_end_timer_timeout() -> void:
	if player.velocity.length() < player.min_slide_velocity:
		finished.emit("Idle")

func enter(previous_state_path: String, data := {}) -> void:
	
	var inital_boost = player.get_move_direction() * player.inital_slide_force
	
	player.velocity += inital_boost
	player.particle_trail.emitting = true
	

func exit() -> void:
	player.model.rotation.x = 0
	player.model.rotation.z = 0

	player.particle_trail.emitting = false
	

func _on_coyote_timer_timeout() -> void:
	can_jump = false

func _on_let_go_sliding_timeout() -> void:
	if player.state != player.STATES.Sliding:
		return

	if is_falling and move_direction.length() != 0:
		finished.emit("Falling")
	




