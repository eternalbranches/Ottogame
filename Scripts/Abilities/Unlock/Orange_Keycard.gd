extends Area2D
const PText := "Orange Keycard acquired"
func _ready():
	if CharacterSave.save_dict["orange_keycard"] == true:
		queue_free()


func _on_Orange_Keycard_body_entered(body):
	CharacterSave.save_dict["orange_keycard"] = true
	visible = false
	body.collect_powerup(PText)
