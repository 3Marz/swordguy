extends State


func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func enter(previous_state_path: String, data := {}) -> void:
	parent.collision_shape.disabled = true
	parent.freeze = true

	parent.anim_player.play("Held")

	parent.disable_trails()
	pass

func exit() -> void:
	pass
