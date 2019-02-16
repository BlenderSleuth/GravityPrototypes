extends Planet

#onready var space_state = get_world().direct_space_state

var debugnode: MeshInstance

#onready var shape: Shape = $CollisionShape.shape
#onready var triangles = shape.get_faces()

var im: ImmediateGeometry


func _ready():
	var m = SphereMesh.new()
	m.radius = 2
	m.height = 4

	debugnode = MeshInstance.new()
	debugnode.mesh = m
	debugnode.material_override = SpatialMaterial.new()
	debugnode.material_override.albedo_color = Color.crimson
#	add_child(debugnode)

	im = ImmediateGeometry.new()
	im.material_override = SpatialMaterial.new()
	im.material_override.albedo_color = Color.crimson
	add_child(im)

	#print(triangles)


func draw_line(from: Vector3, to: Vector3):
		im.clear()
		im.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
		im.add_vertex(from)
		im.add_vertex(to)
		im.end()


var grav_vec := Vector3()
func get_gravity_vec2(player: Player) -> Vector3:
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
	var normal_down := player.raycast_down.get_collision_normal()
	var normal_front := player.raycast_front.get_collision_normal()
	var normal_back := player.raycast_back.get_collision_normal()

	var smoothed_normal := (normal_down*0.4 + normal_front*0.4 + normal_back*0.2).normalized()
	print(normal_down)
	# Cast ray from player position
	#var from = player_transform.origin
	# To 80 units beneath the player, in global coordinates
	#var to = from + player_transform.basis.xform(Vector3(0, -80, 0))

	#var result = space_state.intersect_ray(from, to)
	if smoothed_normal:
		grav_vec = -normal_down

	return grav_vec