extends Area2D
const PText := "Press Spacebar to shoot"

func _ready():
	if CharacterSave.save_dict["gun"] == true:
		queue_free()

func _on_Gun_Unlock_body_entered(body):
	CharacterSave.save_dict["gun"] = true
	visible = false
	body.collect_powerup(PText)
