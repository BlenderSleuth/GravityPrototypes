extends Spatial

class_name Coin

onready var particles = $Particles as Particles
onready var anim = $AnimationPlayer as AnimationPlayer

func _on_area_entered(body):
	if body is Player:
		Main.coin_collected(self)

func collect():
	particles.amount = 100
	particles.process_material.radial_accel = 20
	particles.one_shot = true
	particles.explosiveness = 1
	anim.play("Collected")