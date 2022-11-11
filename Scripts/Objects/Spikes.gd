extends Area2D
var knockback := Vector2(100, 400)
var damage := 10.0

func _ready():
	pass

func _on_Spikes_body_entered(body):
	body.on_hit(damage, "Enemy", global_position, knockback)
