extends Area2D
const PText := "Unlocked walljump"
func _ready():
	if CharacterSave.save_dict["walljump"] == true:
		queue_free()

func _on_Walljump_Unlock_body_entered(body):
	CharacterSave.save_dict["walljump"] = true
	visible = false
	body.collect_powerup(PText)
