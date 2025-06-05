extends RigidBody3D 
class_name Sword

@export var debug := false

@export var return_speed := 10.0

@export var player : Player
@export var curve_point: Node3D

@export var return_accel_curve: Curve

@onready var cylinder_shape := preload("res://Entitys/Sword/throw_sword_cylinder_shape.tres")
@onready var box_shape := preload("res://Entitys/Sword/throw_sword_box_shape.tres")

@onready var anim_player = $AnimationPlayer 
@onready var collision_shape = $CollisionShape3D
@onready var state_machine: StateMachine = $StateMachine

# @onready var trails_root = $SmearSword/Pivot/Trails
@onready var handle_trail: GPUTrail3D = $Pivot/HandleTrail
@onready var blade_trail: GPUTrail3D = $Pivot/BladeTrail

var collision_point : Vector3
var collision_normal: Vector3

# DEBUG
var points = []

func enable_trails():
	# trails_root.visible = true
	handle_trail.length = 5
	blade_trail.length = 10
	pass
func disable_trails():
	# trails_root.visible = false
	handle_trail.length = 0
	blade_trail.length = 0
	pass


func return_to_pos(pos: Vector3, player: Player) -> void:
	anim_player.play("Spin")
	collision_shape.disabled = true

	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", pos, 0.8)


func _physics_process(delta: float) -> void:
	if debug:
		for point in points:
			DebugDraw3D.draw_sphere(point[0], 0.1, Color.RED)
			DebugDraw3D.draw_line(point[0], point[0] + point[1] * 2, Color.BISQUE)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if state.get_contact_count() > 0:
		if state.get_contact_collider_object(0) != Player:
			collision_point = state.get_contact_local_position(0)
			collision_normal = state.get_contact_local_normal(0)

			if debug:
				points.append([collision_point, collision_normal])

func _on_hit_area_body_entered(body: Node3D) -> void:
	pass
