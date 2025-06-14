extends Node
class_name GameController

@export var world: Node3D
@export var gui: Control

@export var start_gui_scene: PackedScene
@export var start_world_scene: PackedScene

var current_world_scene: Node3D
var current_gui_scene: Control

func _ready() -> void:
	Global.game_controller = self

	if start_gui_scene != null:
		change_gui_scene(start_gui_scene.resource_path)
	if start_world_scene != null:
		change_world_scene(start_world_scene.resource_path)

func change_gui_scene(new_scene: String, delete: bool = true, keep_running: bool = false) -> void:
	if current_gui_scene != null:
		if delete:
			current_gui_scene.queue_free()
		elif keep_running:
			current_gui_scene.visible = false
		else:
			gui.remove_child(current_gui_scene)
	
	var new = load(new_scene).instantiate()
	gui.add_child(new)
	current_gui_scene = new
	
func change_world_scene(new_scene: String, delete: bool = true, keep_running: bool = false) -> void:
	if current_world_scene != null:
		if delete:
			current_world_scene.queue_free()
		elif keep_running:
			current_world_scene.visible = false
		else:
			world.remove_child(current_world_scene)
	
	var new = load(new_scene).instantiate()
	world.add_child(new)
	current_world_scene = new

