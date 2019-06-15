extends Spatial

onready var player = $Player as Player

var planets = []

func _ready() -> void:
    for child in get_children():
        if child.name.begins_with("Planet"):
            planets.append(child)
        if child.name.begins_with("DieBox"):
            child.connect("body_exited", self, "_on_player_die")

    for planet in planets:
        planet.connect("player_entered_gravity_influence", self, "change_player_gravity")

func change_player_gravity(planet) -> void:
    player.planet = planet

func _process(delta: float) -> void:
    OS.set_window_title("fps: " + str(Engine.get_frames_per_second()))

# Called when player should die
func _on_player_die(body):
    if body == player:
        Main.reset_scene()


func _on_Portal_body_entered(body: Node) -> void:
    if body == player:
        Main.next_scene()

