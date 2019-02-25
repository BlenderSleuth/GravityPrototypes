extends Spatial

onready var player: Player = $Player


func _process(delta: float) -> void:
	OS.set_window_title("fps: " + str(Engine.get_frames_per_second()))

# Called when player should die
func _on_player_die(body):
	if body == player:
		Main.reset_scene()


func _on_Portal_body_entered(body: Node) -> void:
	if body == player:
		Main.next_scene()
