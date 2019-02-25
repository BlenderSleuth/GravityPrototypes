extends StaticBody

class_name Planet

var grav_vec := Vector3(0, -1, 0)

# Return normalized vector pointing in direction of gravity
func get_gravity_vec(player_transform: Transform) -> Vector3:
	return grav_vec

func reset_gravity() -> void:
	print("hi there")
	grav_vec = Vector3(0, -1, 0)