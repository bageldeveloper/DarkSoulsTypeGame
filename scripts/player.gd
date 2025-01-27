extends CharacterBody3D

@onready var camera_mount = $camera_mount
@onready var animation_player = $visuals/knight/AnimationPlayer

@onready var visuals = $visuals
var roll_direction
var rolling = false
var SPEED = 3
const JUMP_VELOCITY = 4.5
const rotate_sens = 0.5
var walking_speed = 3.0
var running_speed = 5.0
var air_control = 5.0
var air_velocity_x = velocity.x
var air_velocity_z = velocity.z
var running = false
var last_direction = Vector3(0, 0, 1)
@onready var roll_window = $roll_window

var roll_magnitude = 8.0

var is_locked = false

@export var sens_horizontal = 0.5
@export var sens_vertical = 0.5
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion: 
		rotate_y(deg_to_rad(-event.relative.x*sens_horizontal))
		visuals.rotate_y(deg_to_rad(event.relative.x * sens_horizontal))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y*sens_vertical))
		camera_mount.rotation.x = clamp(camera_mount.rotation.x, deg_to_rad(-90), deg_to_rad(30))

func _physics_process(delta):
	if !animation_player.is_playing():
		is_locked = false
	if Input.is_action_just_pressed("kick"):
		if animation_player.current_animation != "kick":
			animation_player.play("kick")
			is_locked = true
	if Input.is_action_just_pressed("run"):
		if $roll_window.is_stopped():
			$roll_window.start()
	if Input.is_action_pressed("run"):
		SPEED = running_speed
		running = true
	else:
		SPEED = walking_speed
		running = false
	
	
	# Add the gravity.
	

	# Handle jump.
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction.x != 0 or direction.x != 0:
		last_direction = direction
	if direction and !is_locked:
		if running:
			if animation_player.current_animation != "running":
				animation_player.play("run")
		else:
			if animation_player.current_animation != "walking":
				animation_player.play("walk")

		visuals.rotation.y = lerp_angle(visuals.rotation.y, atan2(input_dir.x, input_dir.y), .25)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		if !is_locked:
			if animation_player.current_animation != "idle":
				animation_player.play("idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		air_velocity_x = velocity.x
		air_velocity_z = velocity.z
	if not is_on_floor():
		velocity.y -= gravity * delta
		air_velocity_x += direction.x * delta * air_control
		air_velocity_z += direction.z * delta * air_control
		if air_velocity_x / direction.x > SPEED:
			air_velocity_x = direction.x * SPEED
		if air_velocity_z / direction.z > SPEED:
			air_velocity_z = direction.z * SPEED
		velocity.x = air_velocity_x
		velocity.z = air_velocity_z
		
		
	if Input.is_action_just_released("run"):
		if !$roll_window.is_stopped() and !rolling and is_on_floor():
			is_locked = true
			rolling = true
			animation_player.play("roll")
			roll_direction = last_direction
	if rolling:
		velocity.x = roll_direction.x * roll_magnitude
		velocity.z = roll_direction.z * roll_magnitude
		if animation_player.current_animation != "roll":
			rolling = false
			is_locked = false
	if !is_locked or rolling:
		move_and_slide()
