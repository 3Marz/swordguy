extends State

var body: Node3D

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:

	if body != null and body is MovingPlatform:
		parent.position += body.velocity
		# parent.rotation += body.angular_velocity


func enter(previous_state_path: String, data := {}) -> void:
	parent.collision_shape.disabled = false
	parent.freeze = true

	# parent.disable_trails()
	parent.sword_mesh.layers = parent.CULL_MASK_WITH_SHADOW

	if data["body"] != null:
		body = data["body"]
	
	var random_offset = Vector3(randf_range(-0.06, 0.06), randf_range(-0.06, 0.06), randf_range(-0.06, 0.06))
	var random_depth_factor = randf_range(0.25, 0.8)

	parent.global_position = parent.collision_point + parent.collision_normal * random_depth_factor
	parent.global_transform = parent.global_transform.looking_at(parent.collision_point + (parent.collision_normal + random_offset))

	parent.anim_player.play("Hit")
	# print(parent.collision_normal)

func exit() -> void:
	parent.sword_mesh.layers = parent.CULL_MASK_NO_SHADOW
	pass
