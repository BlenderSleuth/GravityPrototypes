extends Planet

func get_gravity_vec(player_transform: Transform) -> Vector3:
	# Define gravity line: point on line (a) and vector (n) in direction of line
	var a = transform.origin
	var n = transform.basis.y
	# Point to find closest point on line to
	var p = player_transform.origin

	# Vector pointing perpindicular to line and player
	return ((a + (p - a).dot(n) * n) - p).normalized()