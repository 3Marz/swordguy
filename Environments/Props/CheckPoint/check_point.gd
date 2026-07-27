extends Node3D
class_name CheckPoint

@export var invisible: bool = false
@export var respawn_point: Marker3D

@onready var anim_player: AnimationPlayer = $Model/AnimationPlayer
@onready var static_collision_shape: CollisionShape3D = $StaticBody3D/CollisionShape3D
@onready var outline: MeshInstance3D = $Model/Gem/GemOutline

var enabled := false:
	set(value):
		enabled = value
		if enabled:
			_trigger_enable_animation()
		else:
			_trigger_disabled()

func _trigger_enable_animation() -> void:
	anim_player.play("enable")
	anim_player.queue("enable_loop")
	outline.visible = true

func _trigger_disabled():
	anim_player.play("disabled")
	outline.visible = false

func _ready() -> void:
	if invisible:
		visible = false
		static_collision_shape.disabled = true


func _on_area_body_entered(body: Node3D) -> void:
	if body is Player:
		body.health.heal(3)
		if !enabled:
			enabled = true
			Global.game_controller.current_world_scene.current_checkpoint.enabled = false
			Global.game_controller.current_world_scene.current_checkpoint = self

			# TODO: reset player health
