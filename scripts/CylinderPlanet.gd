extends Planet

func get_gravity_vec(player_transform: Transform) -> Vector3:
	# Define gravity line: point on line (a) and vector (n) in direction of line
	var a = transform.origin
	var n = transform.basis.y
	# Point to find closest point on line to
	var p = player_transform.origin

	# Closest point from player position to line from a to a+n
	var closest_point = Geometry.get_closest_point_to_segment_uncapped(p, a, a+n)

	# Gravity vector from p to closest point
	var grav_vec = (closest_point - p).normalized()

	# Vector pointing perpindicular to line and player
	return grav_vec