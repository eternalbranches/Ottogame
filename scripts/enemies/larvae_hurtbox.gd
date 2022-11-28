extends Area2D

var state = "idle"
onready var larvae = $"../.."
	
func player_enters_range(activate : bool) -> void:
	if activate == true:
		larvae.active = true


func on_hit(damage : float, _origin : String, enemy_pos : Vector2, knockback : Vector2) -> void:
	larvae.on_hit(damage, _origin, enemy_pos, knockback)
