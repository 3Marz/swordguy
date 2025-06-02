extends State


func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func enter(previous_state_path: String, data := {}) -> void:
	parent.collision_shape.disabled = false
	parent.freeze = false

	parent.anim_player.play("Spin")

	parent.enable_trails()
	pass

func exit() -> void:
	pass




func _on_throw_sword_body_entered(body:Node) -> void:
	if body is Player:
		return

	finished.emit("Land", {"body": body})


