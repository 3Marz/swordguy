class_name Player
extends CharacterBody3D

# ---------- VARIABLES ---------- #

@export var debug := false

@export_category("Player General Properties")
@export var max_speed : float = 5.5
@export var max_fast_speed : float = 6.2
@export var accel_to_fastspeed_factor: float = 2
@export var deaccel_to_normalspeed_factor: float = 1

@export var model_tilt_speed: float = 1.0
@export var model_tilt_multiplier: float = -4.0
@export var max_tilt_angle: float = 180

# @export var wall_jump_force : float = 9

# for how fast our player model chatch up to the look input in air
@export var model_follow_factor: float = 10

@export var air_deaccel_factor: float = 0.05

@export var max_throw_count: int = 2

@export var max_fall_y_velocity: float = -25

#------------------------------------------------------------#
@export_category("States")

@export_group("Idle")
@export var deaccel_factor: float = 10

@export_group("Running")
@export var accel_factor: float = 0.3
@export var curve_sample_rate: float = 0.08
@export var accelcurve: Curve
@export var min_slop_angle: float = 0.5

@export_group("Jumping")
@export var jump_force : float = 10.5
@export var jump_height_cut : float = 0.65

@export_group("Sliding")
@export var inital_slide_force : float = 5.0
@export var slide_move_speed : float = 5.0
@export var slide_deaccel : float = 0.01
@export var downhill_multiplier_step : float = 0.01
@export var max_slop_velo_length : float = 9.0
@export var min_slide_velocity : float = 3.0
@export var slide_velocity_for_longjump: float = 7.0

@export_group("Long Jump")
@export var long_jump_height : float = 8
@export var long_jump_force : float = 3
@export var long_jump_turn_speed : float = 4
@export var long_jump_air_deaccel_factor : float = 0.05
@export var max_long_jump_velo_length : float = 10;

@export_group("Throwing Sword")
@export var sword_throw_force : float = 800
@export var sword_throw_jump_boost : float = 1
@export var sword_throw_player_deaccel : float = 5
@export var sword_throw_jump_speed : float = 3
@export var throwing_model_follow_factor : float = 15
@export var sword_throw_cooldown_time : float = 0.01

@export_group("Throwing Sword Down")
@export var sword_throw_down_force : float = 800
@export var sword_throw_down_jump_boost : float = 1
@export var sword_throw_down_player_deaccel : float = 5
@export var sword_throw_down_jump_speed : float = 3
@export var sword_throw_down_cooldown_time : float = 0.15

@export_group("Sword Reflect")
@export var reflect_knockback: float = 5

@export_group("Ledge Grab")
@export var horizantal_ledge_offset : float = 1
@export var	vertical_ledge_offset : float = 1
@export var min_ledge_angle: float = 0.8
@export var model_forward_offset: float = 0.1
@export var time_to_ledge: float = 0.2
@export var ledge_move_deadzone: float = 0.4
@export var ledge_letgo_deadzone: float = 0.7
@export var ledge_stopping_distance: float = 0.08
@export var ledge_speed: float = 1.5

@export_group("Sharp Turn")
@export var sharp_turn_deaccel_factor: float = 15
@export var sharp_turn_min_velo_length: float = 4
@export var sharp_turn_deadzone: float = 0.1

@export_group("Sitting On Pole")
@export var sitting_on_pole_deadzone: float = 0.75
@export var sitting_on_pole_accel_factor: float = 12
@export var sitting_on_pole_model_follow_factor: float = 5
@export var sitting_on_pole_added_force: float = 2
#------------------------------------------------------------#

@export_category("Others")
@export_group("Animation Blend Factors")
@export var global_blend := 10
@export var fall_blend := 5

@export_group("Game Juice")
@export var jumpStretchSize := Vector3(0.8, 1.2, 0.8)
@export var landStretchSize := Vector3(1.2, 0.8, 1.2)

@export_group("Camera Settings")
@export var mouse_sensitivity: float = 2.0
@export var inverse_horz: bool = false
@export var inverse_vert: bool = false
@export var min_pitch: float = -90
@export var max_pitch: float = 90
@export var min_spring_length: float = 1.5
@export var max_spring_length: float = 5.5

# Onready Variables
@onready var model: Node3D = $Model
@onready var player_model: Node3D = $Model/Armature
@onready var skeleton : Skeleton3D = $Model/Armature/Skeleton3D
@onready var sword_mesh = $Model/Armature/Skeleton3D/Sword/Sword
@onready var anim_tree: AnimationTree = $AnimationTree

@onready var ledge_ray : RayCast3D = $Raycasts/LedgeRay
@onready var ledge_ray_left : RayCast3D = $Raycasts/LedgeRayLeft
@onready var ledge_ray_right : RayCast3D = $Raycasts/LedgeRayRight
@onready var ledge_ray_horizontal : RayCast3D = $Raycasts/LedgeRayHorizontal
@onready var wall_check_ray : RayCast3D = $Raycasts/WallCheckRay

@onready var sword_spwan_pos : Marker3D = $SwordSpawnPoints/SwordSpawnNormal
@onready var sword_down_spwan_pos : Marker3D = $SwordSpawnPoints/SwordSpawnDownward

@onready var state_machine: StateMachine = $StateMachine

@onready var particle_trail: GPUParticles3D = $Particles/ParticleTrail
@onready var sharp_turn_particle: GPUParticles3D = $Particles/SharpTurn

@onready var sword_body: Sword = $SwordSocket/offset/Sword

@onready var sword_return_cooldown_timer: Timer = $Timers/return_sword_cooldown

#----------------------------------------------

@export var pcam: PhantomCamera3D

var gravity = 25
var wall_slide_gravity = 5

# Booleans
var jump_just_pressed = false
var has_sword = true
var can_return_sword = true

var previous_y_rotation: float = 0.0
var delta_rotation: float = 0.0  # Change since last frame

var used_speed: float = max_speed # Used Speed Depending on if moving downword on a slop or not
var moving_to_fast_speed = false # for debuging

var throw_count = 0

var state = 0
enum STATES {
	Idle,
	Running,
	WallSliding,
	Jumping,
	Falling,
	Throwing_Sword,
	Sliding,
	Long_Jump,
	Ledge_Grab,
	Sword_Return,
	Throwing_Sword_Down,
	Sword_Reflect,
	Sharp_Turn,
	Sitting_On_Pole
}

const COLLISION_MASK_WITH_SWORD = 1 | 4 | 16
const COLLISION_MASK_NO_SWORD = 1 | 16

# ---------- FUNCTIONS ---------- #
#
func _unhandled_input(event):

	# print(Input.get_vector("look_left", "look_right", "look_up", "look_down"))	

	if event is InputEventMouseMotion and pcam != null:
		var pcam_rotation_degrees = pcam.get_third_person_rotation_degrees()

		pcam_rotation_degrees.x -= event.relative.y * mouse_sensitivity * (-1 if inverse_vert else 1)
		pcam_rotation_degrees.x = clampf(pcam_rotation_degrees.x, min_pitch, max_pitch)
		pcam_rotation_degrees.y -= event.relative.x * mouse_sensitivity * (-1 if inverse_horz else 1)
		
		var tilt_scaler = 1.0 - (pcam_rotation_degrees.x - min_pitch) / (max_pitch - min_pitch)
		pcam.spring_length = lerp(min_spring_length, max_spring_length, tilt_scaler)

		pcam.set_third_person_rotation_degrees(pcam_rotation_degrees)

func _ready() -> void:
	anim_tree.active = true

	# Engine.time_scale = 0.3

func _physics_process(delta: float) -> void:
	controller_camera_control(delta)

	if is_on_floor():
		throw_count = 0

	rotation.y += deg_to_rad(get_platform_angular_velocity().y)
	var current_y_rotation = rotation.y
	delta_rotation = wrapf(current_y_rotation - previous_y_rotation, -PI, PI)
	previous_y_rotation = current_y_rotation

	jump_just_pressed = Input.is_action_just_pressed("jump")

	if is_on_floor():
		if get_floor_angle() > min_slop_angle and get_last_motion().y < 0:
			used_speed = lerpf(used_speed, max_fast_speed + get_floor_angle(), accel_to_fastspeed_factor * delta)
			moving_to_fast_speed = true
		else:
			used_speed = lerpf(used_speed, max_speed, deaccel_to_normalspeed_factor * delta)
			moving_to_fast_speed = false

	if debug:
		DebugDraw3D.draw_arrow(global_position+Vector3(0,1,0), (global_position+Vector3(0,1,0)) + velocity, Color.BLUE if !moving_to_fast_speed else Color.RED, 0.1)

		DebugDraw2D.set_text("FPS", str(Engine.get_frames_per_second()))
		DebugDraw2D.set_text("player_state", $StateMachine.get_child(state).name)
		DebugDraw2D.set_text("player_velocity", velocity)
		DebugDraw2D.set_text("player_velocity_length", velocity.length())
		DebugDraw2D.set_text("rotation_change", str(delta_rotation))

func cam_follow(delta):
	if !pcam:
		return

func controller_camera_control(delta):
	if Input.get_connected_joypads().size() > 0 and pcam != null:
		var axis = Input.get_vector("look_left", "look_right", "look_up", "look_down")
		var pcam_rotation_degrees = pcam.get_third_person_rotation_degrees()

		pcam_rotation_degrees.x -= (axis.y * 3) * (-1 if inverse_vert else 1)
		pcam_rotation_degrees.x = clampf(pcam_rotation_degrees.x, min_pitch, max_pitch)
		pcam_rotation_degrees.y -= (axis.x * 3) * (-1 if inverse_horz else 1)

		var tilt_scaler = 1.0 - (pcam_rotation_degrees.x - min_pitch) / (max_pitch - min_pitch)
		pcam.spring_length = lerp(min_spring_length, max_spring_length, tilt_scaler)

		pcam.set_third_person_rotation_degrees(pcam_rotation_degrees)

func apply_gravity(delta, custom_gravity = gravity):
	var used_gravity = custom_gravity
	velocity.y -= used_gravity * delta
	if velocity.y <= max_fall_y_velocity:
		velocity.y = max_fall_y_velocity

func get_move_direction(only_x = false) -> Vector3:
	var move_direction := Vector2.ZERO
	if only_x:
		move_direction = Vector2(Input.get_axis("move_right", "move_left"), 0)
	else:
		move_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	return Vector3(move_direction.x, 0, move_direction.y).rotated(Vector3.UP, pcam.get_third_person_rotation().y).normalized()

func update_sword_visability():
	if has_sword:
		sword_mesh.show()
	else:
		sword_mesh.hide()

func return_sword():
	if sword_body.state_machine.state.name != "Return":
		sword_body.state_machine._transition_to_next_state("Return", {})

func _reparent(new_parent):
	pcam.set_follow_target(null)
	reparent(new_parent)
	pcam.set_follow_target(self)

func can_throw_n_return_sword(single_func: Signal):
	if Input.is_action_just_pressed("throw"):
		if has_sword and throw_count < max_throw_count:
			single_func.emit("Throwing Sword")
		elif !has_sword and can_return_sword:
			return_sword()

func _on_state_machine_state_changed(prev:String, next:String) -> void:
	for i in $StateMachine.get_child_count():
		if $StateMachine.get_child(i).name == next:
			state = i
	# state = next

func _on_return_back_to_player() -> void:
	if (state == STATES.Falling or 
			state == STATES.Jumping or 
			state == STATES.Idle or 
			state == STATES.Running or
			state == STATES.Long_Jump) and throw_count < max_throw_count:
		state_machine._transition_to_next_state("Sword Return", {})

func _on_return_sword_cooldown_timeout() -> void:
	can_return_sword = true




