extends Planet

func get_gravity_vec(player_transform: Transform) -> Vector3:
	return (transform.origin - player_transform.origin).normalized()