extends Planet


onready var collision: CollisionObject = $CollisionShape
onready var shape: Shape = collision.shape
onready var triangles: PoolVector3Array = shape.get_faces()

var debugnode: ImmediateGeometry

# Dictionary to store the normal for each vertes
var vertex_normals := {}

# Triangle normal for anti-clockwise winding
func triangle_normal(v0: Vector3, v1: Vector3, v2: Vector3) -> Vector3:
	return (v1-v0).cross(v2-v0)

# Calculate and store smoothed vertex normals
func calculate_vertex_normals() -> void:
	for i in range(triangles.size()/3):
#		var v0 = collision.transform.xform(triangles[i*3+0])
#		var v1 = collision.transform.xform(triangles[i*3+1])
#		var v2 = collision.transform.xform(triangles[i*3+2])
		var v0 = triangles[i*3+0]
		var v1 = triangles[i*3+1]
		var v2 = triangles[i*3+2]

		var normal = triangle_normal(v0, v1, v2)

		if vertex_normals.has(v0):
			vertex_normals[v0] += normal
		else:
			vertex_normals[v0] = normal

		if vertex_normals.has(v1):
			vertex_normals[v1] += normal
		else:
			vertex_normals[v1] = normal

		if vertex_normals.has(v2):
			vertex_normals[v2] += normal
		else:
			vertex_normals[v2] = normal

	# Normalise vertex normals
	for vertex in vertex_normals.keys():
		vertex_normals[vertex] = vertex_normals[vertex].normalized()


func _ready() -> void:
	# Make debugnode
	debugnode = ImmediateGeometry.new()
	debugnode.material_override = SpatialMaterial.new()
	debugnode.material_override.albedo_color = Color.crimson
	add_child(debugnode)

	calculate_vertex_normals()

	# Debug draw vertex normals:
	var length = 5
	for vertex in vertex_normals.keys():
		var from = collision.transform.basis.xform(vertex)
		var to = from + collision.transform.basis.xform(vertex_normals[vertex])*length
		draw_line(from, to)


# Debug draw lines
var drawn_lines := {}
func draw_line(from: Vector3, to: Vector3) -> void:
	drawn_lines[from] = to
func remove_line(from) -> void:
	drawn_lines.erase(from)

var drawn_triangles := {}
func draw_triangle(v0: Vector3, v1: Vector3, v2: Vector3) -> void:
	drawn_triangles[v0] = [v1, v2]
func remove_triangle(v0) -> void:
	drawn_triangles.erase(v0)

func _process(delta: float) -> void:
	debugnode.clear()
	for from in drawn_lines.keys():
		var to = drawn_lines[from]
		debugnode.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
		debugnode.add_vertex(from)
		debugnode.add_vertex(to)
		debugnode.end()
	for v0 in drawn_triangles.keys():
		var v1 = drawn_triangles[v0][0]
		var v2 = drawn_triangles[v0][1]
		debugnode.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP, null)
		debugnode.add_vertex(v0)
		debugnode.add_vertex(v1)
		debugnode.add_vertex(v2)
		remove_triangle(v0)
		debugnode.end()

# Geometric math functions
func find_triangle(from: Vector3, dir: Vector3) -> Array:
	# Homebrew raycast through mesh
	for i in range(triangles.size()/3):
		var v0 = triangles[i*3+0]
		var v1 = triangles[i*3+1]
		var v2 = triangles[i*3+2]
		var intersection = Geometry.ray_intersects_triangle(from, dir, v0, v1, v2)
		if intersection is Vector3:
			return [v0, v1, v2, intersection]

	return []

# Returns if c is to the right of line ab
func edge_function(a: Vector2, b: Vector2, c: Vector2) -> float:
	return (c.x - a.x) * (b.y - a.y) - (c.y - a.y) * (b.x - a.x)


func get_smoothed_normal(from: Vector3, dir: Vector3) -> Vector3:
	var smoothed_normal := Vector3()

	var triangle = find_triangle(from, dir)
	if triangle:
		# Extract points
		var v0 := triangle[0] as Vector3
		var v1 := triangle[1] as Vector3
		var v2 := triangle[2] as Vector3
		var intersection := triangle[3] as Vector3

		# Rotate to 2D local triangle coordinates
		var normal := triangle_normal(v0, v1, v2).normalized()
		var axis := normal.cross(Vector3.UP).normalized()
		var angle := normal.angle_to(Vector3.UP)

		v0 = v0.rotated(axis, angle)
		v1 = v1.rotated(axis, angle)
		v2 = v2.rotated(axis, angle)
		intersection = intersection.rotated(axis, angle)

		# Discard y axis
		var v0_2D := Vector2(v0.x, v0.z)
		var v1_2D := Vector2(v1.x, v1.z)
		var v2_2D := Vector2(v2.x, v2.z)
		var p := Vector2(intersection.x, intersection.z)

		# 2x area of triangle
		var area := edge_function(v0_2D, v1_2D, v2_2D)
		# Barycentric coordinates
		var w0 := edge_function(v1_2D, v2_2D, p) / area
		var w1 := edge_function(v2_2D, v0_2D, p) / area
		var w2 := edge_function(v0_2D, v1_2D, p) / area

		# Find vertex normals for current triangle
		var v0_normal := vertex_normals[triangle[0]] as Vector3
		var v1_normal := vertex_normals[triangle[1]] as Vector3
		var v2_normal := vertex_normals[triangle[2]] as Vector3

		# Interpolate vertex normals with barycentric coordinates to get a smoothed normal
		smoothed_normal = w0 * v0_normal + w1 * v1_normal + w2 * v2_normal

		# Debug draw intersected triangle
		#v0 = collision.transform.xform(triangle[2])
		#v1 = collision.transform.xform(triangle[1])
		#v2 = collision.transform.xform(triangle[0])
		#draw_triangle(v0, v1, v2)

	return smoothed_normal


var grav_vec := Vector3()
func get_gravity_vec(player_transform: Transform) -> Vector3:

	var ray_length := 80
	var from := player_transform.origin
	var dir := player_transform.basis.xform(Vector3.DOWN) * ray_length

	# Find in local mesh coordinates to do a proper raycast
	var local_from = collision.transform.xform_inv(from)
	var local_dir = collision.transform.xform_inv(dir)

	var smoothed_normal = get_smoothed_normal(local_from, local_dir)

	if smoothed_normal:
		grav_vec = -collision.transform.xform(smoothed_normal)


	return grav_vec