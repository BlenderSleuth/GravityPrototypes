extends Spatial


var frame = 0
func _process(delta: float) -> void:
	if frame == 1:
		# Remove all children after 1 frame
		for child in get_children():
			remove_child(child)
		set_process(false)

	frame += 1