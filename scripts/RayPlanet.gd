extends Planet


onready var gravity_surface: GravitySurface = $GravitySurface


var grav_vec := Vector3()
func get_gravity_vec(player_transform: Transform) -> Vector3:

	var ray_length := 160
	var from := player_transform.origin
	var dir := player_transform.basis.xform(Vector3.DOWN) * ray_length

	# Find in local mesh coordinates to do a proper raycast
	var local_from = gravity_surface.transform.xform_inv(from)
	var local_dir = gravity_surface.transform.xform_inv(dir)

	var smoothed_normal = gravity_surface.get_smoothed_normal(local_from, local_dir)

	if smoothed_normal:
		grav_vec = -gravity_surface.transform.xform(smoothed_normal)


	return grav_vec