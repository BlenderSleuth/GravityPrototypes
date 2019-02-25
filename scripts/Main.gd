extends Node



var level_paths = [
	"LinearLevel",
	"SphereLevel1",
	"Cylinder/CylinderLevel",
	"CubeLevel",
	"PathLevel"
]

var levels = []

var current_level_idx = 0
var current_scene = null

func _ready() -> void:
	for level_path in level_paths:
		var path = "res://scenes/%s.tscn" % level_path
		# Load the new scene
		var s = load(path)
		levels.append(s)

	print("done loading")

	# Add it to the active scene, as child of root.
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)

	#reset_scene()


func reset_scene() -> void:
	call_deferred("_deferred_goto_scene")

func next_scene() -> void:
	current_level_idx += 1
	if current_level_idx >= level_paths.size():
		current_level_idx = 0

	call_deferred("_deferred_goto_scene")

func _deferred_goto_scene() -> void:
	# It is now safe to remove the current scene
	if current_scene:
		current_scene.free()

	# Instance the new scene.
	current_scene = levels[current_level_idx].instance()

	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(current_scene)