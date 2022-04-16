extends Area2D
const PText := "Doublejump unlocked"

func _ready():
	if CharacterSave.save_dict["doublejump"] == true:
		queue_free()


func _on_Doublejump_Unlock_body_entered(body):
	CharacterSave.save_dict["doublejump"] = true
	visible = false
	body.collect_powerup(PText)
	$AudioStreamPlayer2D.play()
	set_collision_mask_bit(1,0)

func _on_AudioStreamPlayer2D_finished():
	queue_free()
