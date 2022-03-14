extends Area2D
const PText := "Press CTRL/STRG to crawl"

func _ready():
	if CharacterSave.save_dict["crawling"] == true:
		queue_free()
func _on_Crawling_Unlock_body_entered(body):
	CharacterSave.save_dict["crawling"] = true
	visible = false
	body.collect_powerup(PText)
