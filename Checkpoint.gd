extends Area2D

var checkpoint_number := 0

func _ready():
	pass


func _on_Checkpoint_body_entered(body):
	CharacterSave.save_dict["current_checkpoint"] = checkpoint_number
	CharacterSave.save_progress()
