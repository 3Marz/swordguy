extends Node3D
class_name WorldTemplate

@export var start_checkpoint: CheckPoint

@onready var player_follow_pcam: PhantomCamera3D = $PlayerFollowPCam
@onready var player_scene: PackedScene = preload("res://Entitys/Player/player.tscn")

var current_checkpoint: CheckPoint

func _ready() -> void:
	if start_checkpoint:
		current_checkpoint = start_checkpoint
		start_checkpoint.enabled = true
		spawn_player()

func spawn_player():
	var player = player_scene.instantiate()
	player_follow_pcam.follow_mode = PhantomCamera3D.FollowMode.THIRD_PERSON
	player_follow_pcam.follow_target = player
	player.pcam = player_follow_pcam

	player.global_position = current_checkpoint.respawn_point.global_position
	player.rotation.y = current_checkpoint.respawn_point.rotation.y
	player_follow_pcam.rotation.y = -current_checkpoint.respawn_point.rotation.y

	add_child(player)


