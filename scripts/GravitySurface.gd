extends MeshInstance

class_name GravitySurface

# Array of triangles in clockwise winding
onready var triangles: PoolVector3Array = mesh.get_faces()

# Dictionary to store the normal for each vertes
var vertex_normals := {}

func _ready() -> void:
	calculate_vertex_normals()


# Triangle normal for clockwise winding
func triangle_normal(v0: Vector3, v1: Vector3, v2: Vector3) -> Vector3:
	return (v1-v2).cross(v0-v2)

# Calculate and store smoothed vertex normals
func calculate_vertex_normals() -> void:
	for i in range(triangles.size()/3):
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


class TriangleSort:
	static func sort(a, b) -> bool:
		return a[0] < b[0]

# Finds the triangle in the mesh with a ray
func find_triangle(from: Vector3, dir: Vector3) -> Array:
	# Homebrew raycast through mesh
	var possible_triangles = []
	for i in range(triangles.size()/3):
		var v0 = triangles[i*3+0]
		var v1 = triangles[i*3+1]
		var v2 = triangles[i*3+2]
		var intersection = Geometry.ray_intersects_triangle(from, dir, v0, v1, v2)
		if intersection is Vector3:
			possible_triangles.append([(intersection-from).length_squared(), v0, v1, v2, intersection])

	# Sort triangles based on distance to ray origin
	possible_triangles.sort_custom(TriangleSort, "sort")

	# Return closest
	if not possible_triangles.empty():
		var triangle = possible_triangles.front().duplicate(true)
		possible_triangles.clear()
		triangle.pop_front()
		return triangle

	return []

# Returns positive if c is to the right of line ab
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
		smoothed_normal = Basis(v0_normal, v1_normal, v2_normal).xform(Vector3(w0, w1, w2))
		# Equivalent to:
		# smoothed_normal = w0 * v0_normal + w1 * v1_normal + w2 * v2_normal


	return smoothed_normal
