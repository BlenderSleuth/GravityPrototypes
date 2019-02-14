extends Spatial

onready var player = $Player
onready var player_start = Transform()


func _ready():
	player_start = player.transform

func reset():
	player.transform = player_start

# Called when player should die
func _on_player_die(body):
	if body == player:
		reset()
		player.die()
