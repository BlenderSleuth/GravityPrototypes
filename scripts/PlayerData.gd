extends Node

var player = null

func _ready() -> void:
	player = get_player()

func get_player():
	return get_tree().get_nodes_in_group("player")[0]