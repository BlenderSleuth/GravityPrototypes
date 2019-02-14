extends StaticBody

class_name Planet

# Return normalized vector pointing in direction of gravity
func get_gravity_vec(player_transform: Transform) -> Vector3:
	return Vector3(0, -1, 0)