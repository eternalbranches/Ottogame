extends Area2D
const PText := "Doublejump unlocked"

func _ready():
	if CharacterSave.save_dict["doublejump"] == true:
		queue_free()


func _on_Doublejump_Unlock_body_entered(body):
	CharacterSave.save_dict["doublejump"] = true
	visible = false
	body.collect_powerup(PText)
