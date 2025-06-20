extends Node3D
class_name WorldTemplate

var player: Player

@export var start_checkpoint: CheckPoint
@export var end_respawn_time: float = 3.5

@onready var player_follow_pcam: PhantomCamera3D = $PlayerFollowPCam
@onready var player_scene: PackedScene = preload("res://Entitys/Player/player.tscn")
@onready var main_camera: Camera3D = $MainCamera

var current_checkpoint: CheckPoint

func _ready() -> void:
	if start_checkpoint:
		current_checkpoint = start_checkpoint
		start_checkpoint.enabled = true
		spawn_player()

func spawn_player():
	player_follow_pcam.follow_target = null

	player = player_scene.instantiate()
	player_follow_pcam.follow_mode = PhantomCamera3D.FollowMode.THIRD_PERSON
	player_follow_pcam.follow_target = player
	player.pcam = player_follow_pcam

	player.global_position = current_checkpoint.respawn_point.global_position
	player.rotation.y = current_checkpoint.respawn_point.rotation.y
	player_follow_pcam.set_third_person_rotation(Vector3(0, -current_checkpoint.respawn_point.rotation.y, 0))

	add_child(player)

	player.player_died.connect(_respawn_player)

func _respawn_player():
	var uv_player_pos = main_camera.unproject_position(player.global_position + Vector3(0, 0.6, 0)) / get_viewport().get_visible_rect().size
	await TransitionEffect.start_circle_transition(uv_player_pos, 1.6)

	player.queue_free()
	await player.tree_exited

	spawn_player()

	TransitionEffect.end_circle_transition()
