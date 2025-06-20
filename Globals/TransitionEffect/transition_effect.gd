extends CanvasLayer

@export var default_transition_duration: float = 1.0

@onready var diamond_rect: ColorRect = $DiamondTransition
@onready var circle_rect: ColorRect = $CircleTransition

func _ready() -> void:
	reset_all()

func reset_all() -> void:
	diamond_rect.material.set("shader_parameter/progress", 0.0)
	circle_rect.material.set("shader_parameter/circle_size", 2.0)

#---------diamond transition-----------#
func start_diamond_transition(override_duration: float = default_transition_duration) -> void:
	reset_all()
	await get_tree().create_tween().tween_property(diamond_rect.material, "shader_parameter/progress", 1.0, override_duration).finished

func end_diamond_transition(override_duration: float = default_transition_duration) -> void:
	get_tree().create_tween().tween_property(diamond_rect.material, "shader_parameter/progress", 0.0, override_duration)

#---------circle transition-------------#
func start_circle_transition(circle_pos: Vector2, override_duration: float = default_transition_duration) -> void:
	reset_all()
	circle_rect.material.set("shader_parameter/circle_position", circle_pos)
	await get_tree().create_tween().tween_property(circle_rect.material, "shader_parameter/circle_size", 0.0, override_duration).finished

func end_circle_transition(override_duration: float = default_transition_duration) -> void:
	get_tree().create_tween().tween_property(circle_rect.material, "shader_parameter/circle_size", 2.0, override_duration)
