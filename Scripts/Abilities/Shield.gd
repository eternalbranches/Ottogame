extends Area2D
var origin

func animdirection(direction, E_pos, W_pos):
	$Sprite.visible = true
	set_collision_mask_bit(3, 1)
	if direction == "W":
		$AnimationPlayer.play("Shield_W")
		position = W_pos
		
	else:
		$AnimationPlayer.play("Shield_E")
		position = E_pos
		
	
func _on_Selfdestruct_timeout():
	$Sprite.visible = false
	set_collision_mask_bit(3, 0)


func _on_Shield2_body_entered(body):
	body.queue_free()
