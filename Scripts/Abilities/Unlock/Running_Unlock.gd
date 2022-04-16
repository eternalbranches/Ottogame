extends Area2D
const PText := "Double Tap E or Q to run"

func _ready():
	if CharacterSave.save_dict["running"] == true:
		queue_free()

func _on_Running_Unlock_body_entered(body):
	CharacterSave.save_dict["running"] = true
	visible = false
	body.collect_powerup(PText)
	$AudioStreamPlayer2D.play()
	set_collision_mask_bit(1,0)

func _on_AudioStreamPlayer2D_finished():
	queue_free()
