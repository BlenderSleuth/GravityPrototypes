extends KinematicBody

# Tweakable properties
var gravity = 5
# Move speed
var run_speed = 8
var fly_speed = 1.0
# Dampening
var run_damp = 0.8
var fly_damp = 0.98
# Jump properties
var jump_speed = 14
var jump_time = 0.35 # Time in seconds for control over jump

# Interpolation speed for player rotation, deg/sec
var rot_speed = deg2rad(200)

# Arbitrary measure for how much camera rotation to mouse move distance
var mouse_sensitivity = 0.1

# Planet to be attracted to
export (NodePath) var planet_path
var planet: Planet

# Visual representation of play that is rotated
onready var player_mesh = $PlayerMesh

# Cameras
onready var player_camera = $PlayerCameraControl/PlayerCamera
onready var player_camera_control = $PlayerCameraControl

export (NodePath) var front_camera_path
onready var front_camera = get_node(front_camera_path)

# Player velocity in global coordinates
var velocity = Vector3()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	planet = get_node(planet_path) as Planet
	if not planet:
		print("Planet Problem")
		assert(false)


var using_front_camera = false
func _process(delta):
	# Switch between cameras when tab is pressed
	if Input.is_action_just_pressed("ui_focus_next"):
		# Toggle camera flag
		using_front_camera = !using_front_camera

		if using_front_camera:
			front_camera.make_current()
			# Reset player camera
			player_camera_control.transform.basis = Basis()
		else:
			player_camera.make_current()

	# Let go of mouse if esc is pressed
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


var jumping = false
var timer = 0.0
func jump(delta):
	var newjump = Input.is_action_just_pressed('ui_select')

	# Only reset if it is a new jump, and from the floor
	if newjump and not jumping and is_on_floor():
		jumping = true
		timer = 0.0

	# More of the current jump
	if jumping and timer < jump_time:
		var proportion_completed = timer / jump_time
		# Gradually decrease the jump speed over the time of the jump
		var jump_amount = lerp(jump_speed, 0, proportion_completed)
		timer += delta
		return jump_amount
	else:
		# Finished jumping
		jumping = false

	return 0


func get_movement(delta):
	# Input events
	var right = Input.is_action_pressed('ui_right')
	var left = Input.is_action_pressed('ui_left')
	var forward = Input.is_action_pressed("ui_up")
	var backward = Input.is_action_pressed("ui_down")
	var jump = Input.is_action_pressed('ui_select')

	# Movement velocity in local coordinates, relative to camera
	var move = Vector3()

	# Different speed on ground and in air
	var move_speed = run_speed if is_on_floor() else fly_speed
	if right:
		move.x += move_speed
	if left:
		move.x -= move_speed
	if backward:
		move.z += move_speed
	if forward:
		move.z -= move_speed

	# Make sure player doesn't accelerate too much, clamp vector length
	move = move.normalized() * clamp(move.length(), -move_speed, move_speed)

	# Apply jump
	if jump:
		move.y += jump(delta)
	else:
		jumping = false

	return move


var last_move = Vector3()
# Rotate mesh and collision to face direction of movement
func rotate_forward(local_player_movement, delta):
	local_player_movement.y = 0 # Don't look up!

	var movement = player_camera_control.transform.basis.xform(local_player_movement).normalized()

	# If we have moved
	if movement.length() > 0:
		last_move = movement

	var mesh_basis = player_mesh.transform.basis

	# Find the angle between the current front and last_move vectors
	var front = -mesh_basis.z
	var axis = front.cross(last_move).normalized()
	if axis.length_squared() > 0:
		var angle = front.angle_to(last_move)

		# Rotate around up direction
		var target_rotation = mesh_basis.rotated(axis, angle)
		# Interpolate to new rotation
		var slerped_rotation = Quat(mesh_basis).slerp(target_rotation, 10*delta)

		# Apply slerped rotation
		player_mesh.transform.basis = Basis(slerped_rotation).orthonormalized()


func _physics_process(delta):
	# Gravity vector is calculated by planet
	var grav_vec = planet.get_gravity_vec(transform)

	# Rotate player so down faces gravity
	var down = -transform.basis.y
	var rot_axis = down.cross(grav_vec).normalized()
	if rot_axis.length_squared() > 0:
		# Find the angle to rotate
		var angle = down.angle_to(grav_vec)

		# Update rotation
		var target_rotation = Quat(transform.basis.rotated(rot_axis, angle))
		# Interpolate to new rotation
		var angle_this_frame = rot_speed * delta
		var prop = clamp(angle_this_frame/angle, 0, 1)

		var slerped_rotation = Quat(transform.basis).slerp(target_rotation, prop)
		transform.basis = Basis(slerped_rotation).orthonormalized()

	# Add gravity to velocity
	velocity += grav_vec * gravity

	# Player input, in local coordinates
	var movement = get_movement(delta)

	# Movement is relative to camera, transform to global coordinates
	var global_movement = player_camera_control.global_transform.basis.xform(movement)

	# Apply player movement to velocity
	velocity += global_movement

	# Rotate to face direction of movement
	rotate_forward(movement, delta)

	# Apply friction or air resistance
	var damp = run_damp if is_on_floor() else fly_damp

	velocity = move_and_slide(velocity, -grav_vec) * damp


func _input(event):
	# If the event is a mouse event
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Only use horizontal motion to control camera
		var rot_y = event.relative.x * mouse_sensitivity * -1

		player_camera_control.rotation_degrees += Vector3(0, rot_y, 0)


func die():
	# Reset Velocity and Rotation
	velocity = Vector3()
	player_mesh.transform.basis = Basis()
	last_move = Vector3()
	# Reset Camera
	player_camera_control.transform.basis = Basis()

