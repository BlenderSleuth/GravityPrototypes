extends Spatial

var debugnode: ImmediateGeometry

func _ready() -> void:
	# Make debugnode
	debugnode = ImmediateGeometry.new()
	debugnode.material_override = SpatialMaterial.new()
	debugnode.material_override.albedo_color = Color.crimson
	add_child(debugnode)

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
