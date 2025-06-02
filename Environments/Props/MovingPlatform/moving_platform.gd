extends AnimatableBody3D
class_name MovingPlatform

var previous_position: Vector3
var velocity: Vector3

var previous_rotation: Vector3
var angular_velocity: Vector3

func _physics_process(delta: float) -> void:

	var current_position = position
	velocity = current_position - previous_position
	previous_position = current_position

	var current_rotation = rotation
	angular_velocity = current_rotation - previous_rotation
	previous_rotation = current_rotation
