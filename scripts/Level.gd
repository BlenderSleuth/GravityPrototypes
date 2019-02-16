extends Spatial

onready var player = $Player
onready var player_start = Transform()


func _ready():
	player_start = player.transform

func reset():
	player.transform = player_start

func _process(delta: float) -> void:
	OS.set_window_title("fps: " + str(Engine.get_frames_per_second()))

# Called when player should die
func _on_player_die(body):
	if body == player:
		reset()
		player.die()
