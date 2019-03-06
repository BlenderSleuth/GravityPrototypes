extends StaticBody

class_name Planet

signal player_entered_gravity_influence

func player_entered_gravity_influence(body):
	if body == PlayerData.get_player():
		emit_signal("player_entered_gravity_influence", self)

func _ready() -> void:
	var grav_influence = get_node_or_null("GravityInfluence")
	if grav_influence is Area:
		grav_influence.connect("body_entered", self, "player_entered_gravity_influence")

var grav_vec := Vector3(0, -1, 0)

# Return normalized vector pointing in direction of gravity
func get_gravity_vec(player_transform: Transform) -> Vector3:
	return grav_vec
