extends Camera3D

@export var spring_end: Node3D
@export var follow_speed: float = 5.0

func _physics_process(delta: float) -> void:
	position = lerp(position, spring_end.position, delta * follow_speed)

