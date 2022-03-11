extends Area2D

func _ready():
	pass

func _on_Spikes_body_entered(body):
	body.on_hit(1, "Enemy", global_position.x)
