extends Planet

onready var space_state = get_world().direct_space_state

var debugnode: MeshInstance

func _ready() -> void:

	var m = SphereMesh.new()
	m.radius = 2
	m.height = 4

	debugnode = MeshInstance.new()
	debugnode.mesh = m
	debugnode.material_override = SpatialMaterial.new()
	debugnode.material_override.albedo_color = Color.crimson
#	add_child(debugnode)

var grav_vec := Vector3()
#var player_transform := Transform()

var dt: float
func _physics_process(delta: float) -> void:
	dt = delta

func get_gravity_vec(player_transform: Transform) -> Vector3:
	"""
	Result data:
	{
	   position: Vector3 # point in world space for collision
	   normal: Vector3 # normal in world space for collision
	   collider: Object # Object collided or null (if unassociated)
	   collider_id: ObjectID # Object it collided against
	   rid: RID # RID it collided against
	   shape: int # shape index of collider
	   metadata: Variant() # metadata of collider
	}
	"""

	# Cast ray from player position
	var from = player_transform.origin
	# To 80 units beneath the player, in global coordinates
	var to = from + player_transform.basis.xform(Vector3(0, -80, 0))

	var result = space_state.intersect_ray(from, to)
	if result:

		#debugnode.transform.origin = result.position

		#var angle = grav_vec.angle_to(-result.normal)
		#var prop = (rot_speed * dt)/angle
		# Interpolate normals
		#grav_vec = grav_vec.linear_interpolate(-result.normal, 0.1)

		grav_vec = -result.normal

	return grav_vec