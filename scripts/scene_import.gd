tool
extends EditorScenePostImport

# Debug print of edited node tree
func print_all_nodes(node: Node, level: int):
	var name := node.name
	var s = ""
	for a in range(level):
		s += "  "
	print(s + name)

	for child in node.get_children():
		print_all_nodes(child, level+1)


var scene: Node

func rem(a: String, b: String) -> String:
	var pos = a.find(b)
	if pos >= 0:
		a.erase(pos, b.length())
	return a.strip_edges()
	
		

func setup_grav(node: Node) -> void:
	for child in node.get_children():
		setup_grav(child)
	
	# Option -grav is set, create a gravitational influence area
	if node.name.match("*-grav*") and node is MeshInstance:
		var node_parent = node.get_parent()

		# Create area
		var area := Area.new()
		area.name = "gravity"
		
		area.transform.origin = node.transform.origin
		node_parent.add_child(area)
		area.set_owner(scene)

		var collision_shape: Shape

		# Create convex area
		if node.name.match("*-conv*"):
			collision_shape = (node as MeshInstance).mesh.create_convex_shape()
		else:
			var faces := (node as MeshInstance).mesh.get_faces()
			collision_shape = ConcavePolygonShape.new()
			collision_shape.set_faces(faces)

		# Create collision shape
		var col = CollisionShape.new()
		col.name = "shape"
		col.shape = collision_shape
		area.add_child(col)
		col.set_owner(scene)

		# Create a gravity surface if required
		var gravmesh = node.get_node_or_null("gravmesh")
		if gravmesh is MeshInstance:
			var grav_surface = GravitySurface.new()
			grav_surface.name = "gravity_surface"
			grav_surface.mesh = gravmesh.mesh
			area.add_child(grav_surface)
			grav_surface.set_owner(scene)

		# Don't need mesh node now
		node.free()


func post_import(scene: Object) -> Object:
	self.scene = scene
	
	
	setup_grav(scene as Node)

	# print_all_nodes(scene, 0)

	return scene