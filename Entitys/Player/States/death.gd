extends PlayerState

func physics_update(delta: float) -> void:
	pass

func enter(previous_state_path: String, data := {}) -> void:
	player.can_move_camera = false
	pass

func exit():
	pass
