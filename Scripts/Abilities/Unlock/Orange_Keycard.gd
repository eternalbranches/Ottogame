extends Area2D
const PText := "Orange Keycard acquired"
func _ready():
	if CharacterSave.save_dict["keycards"].has("orange_keycard"):
		queue_free()


func _on_Orange_Keycard_body_entered(body):
	CharacterSave.save_dict["keycards"].push_back("orange_keycard")
	visible = false
	body.collect_powerup(PText)
	$AudioStreamPlayer2D.play()
	set_collision_mask_bit(1,0)

func _on_AudioStreamPlayer2D_finished():
	queue_free()
