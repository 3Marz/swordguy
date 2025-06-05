extends State


var return_progress := 0.0
var return_start_pos : Vector3
var return_start_rotation: Vector3

var speed_multipler = 0.0

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	if abs(parent.global_position.distance_to(parent.get_parent().global_position)) < 0.2:
		parent.global_position = parent.get_parent().global_position
		parent.global_rotation = parent.get_parent().global_rotation
		parent.top_level = false
		parent.player.has_sword = true
		finished.emit("Held")
	else:
		return_progress += (parent.return_speed + (speed_multipler/2)) * _delta
		speed_multipler = parent.global_position.distance_to(parent.get_parent().global_position)

		var accel = parent.return_accel_curve.sample_baked(return_progress / return_start_pos.distance_to(parent.get_parent().global_position))

		parent.global_position = get_bezier_quadratic_curve_point(
			return_start_pos,
			parent.curve_point.global_position,
			parent.get_parent().global_position,
			accel
		)

		parent.global_rotation = get_bezier_quadratic_curve_point(
			return_start_rotation,
			parent.curve_point.global_rotation,
			parent.get_parent().global_rotation,
			accel
		)


func enter(previous_state_path: String, data := {}) -> void:
	parent.collision_shape.disabled = true
	parent.freeze = true

	parent.enable_trails()

	parent.anim_player.play("Spin")

	speed_multipler = parent.global_position.distance_to(parent.get_parent().global_position)

	return_start_pos = parent.global_position
	return_start_rotation = parent.global_rotation

	return_progress = 0.0


	pass

func exit() -> void:
	pass

func get_bezier_quadratic_curve_point(p0: Vector3, p1: Vector3, p2: Vector3, t: float) -> Vector3:
	var u = 1.0 - t
	var tt = t * t
	var uu = u * u
	return (uu * p0) + (2.0 * u * t * p1) + (tt * p2)
