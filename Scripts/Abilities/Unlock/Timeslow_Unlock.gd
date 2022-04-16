extends Area2D
const PText := "Press X to enter bullet time"
func _ready():
	if CharacterSave.save_dict["timeslow"] == true:
		queue_free()
	

func _on_Timeslow_Unlock_body_entered(body):
	CharacterSave.save_dict["timeslow"] = true
	visible = false
	body.collect_powerup(PText)
	$AudioStreamPlayer2D.play()
	set_collision_mask_bit(1,0)

func _on_AudioStreamPlayer2D_finished():
	queue_free()
