extends Node3D
class_name CheckPoint

@export var invisible: bool = false
@export var respawn_point: Marker3D

@onready var anim_player: AnimationPlayer = $Model/AnimationPlayer
@onready var static_collision_shape: CollisionShape3D = $StaticBody3D/CollisionShape3D

var enabled := false:
	set(value):
		enabled = value
		if enabled:
			_trigger_enable_animation()

func _trigger_enable_animation() -> void:
	anim_player.play("enable")
	anim_player.queue("enable_loop")

func _ready() -> void:
	if invisible:
		visible = false
		static_collision_shape.disabled = true


func _on_area_body_entered(body: Node3D) -> void:
	if body is Player:
		if !enabled:
			enabled = true
			Global.game_controller.current_world_scene.current_checkpoint = self
			# TODO: reset player health
