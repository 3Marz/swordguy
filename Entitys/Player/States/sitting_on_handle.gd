extends PlayerState

var sitting_point: Vector3

func physics_update(delta: float) -> void:

	if sitting_point:
		player.global_position = lerp(player.global_position, sitting_point, delta * player.sitting_on_pole_accel_factor)
	
	if player.jump_just_pressed:
		finished.emit("Jumping")
	

func enter(previous_state_path: String, data := {}) -> void:
	sitting_point = data["sitting_point"]
	
	player.velocity = Vector3.ZERO
	


func exit() -> void:
	pass

