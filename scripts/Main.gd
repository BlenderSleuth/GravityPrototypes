extends Node



var level_paths = [
	"LinearLevel",
	"ChangingGravity",
	"CylinderLevel",
	#"CubeLevel",
	"PathLevel"
]

var levels = []

var current_level_idx = 0
var current_scene = null

var coins = 0

func _ready() -> void:
	for level_path in level_paths:
		var path = "res://scenes/Levels/%s.tscn" % level_path
		# Load the new scene
		var s = load(path)
		levels.append(s)

	# Add it to the active scene, as child of root.
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)

# Called when a coin is collected
func coin_collected(coin: Coin) -> void:
	coins += 1
	get_tree().get_nodes_in_group("CoinScore")[0].text = String(coins)
	coin.collect()


func reset_scene() -> void:
	coins = 0
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