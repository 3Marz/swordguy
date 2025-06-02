extends Node3D

# ---------- VARIABLES ---------- #

# Control Mouse Sensitivity through inspector or from here
@export var mouse_sensitivity := 0.2
@export var controller_sensitivity := 2

# @export var controller_cam_deadzone := 0.2

var inverse_horz = false
var inverse_vert = false

# Assign Camera Node here it might be named different in your Project
@onready var camera = $Camera3D

var cam_velocity: Vector2 = Vector2.ZERO

# ---------- FUNCTIONS ---------- #

func _ready():
	# Confining Mouse Cursor in the game view so it doesnt get in the way of gameplay
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Handling Camera Movement
func _unhandled_input(event):
		
	if event is InputEventMouseMotion:
		rotation_degrees.x -= event.relative.y * mouse_sensitivity * (-1 if inverse_vert else 1)
		
		rotation_degrees.y -= event.relative.x * mouse_sensitivity * (-1 if inverse_horz else 1)

func _physics_process(delta: float) -> void:
	var controller_vector = Input.get_vector("look_up", "look_down", "look_left", "look_right")

	cam_velocity = controller_vector * controller_sensitivity

	rotation_degrees.x -= cam_velocity.x;
	rotation_degrees.y -= cam_velocity.y;

	rotation_degrees.x = clamp(rotation_degrees.x, -75, 40)
	rotation_degrees.y = wrapf(rotation_degrees.y, 0, 360)
