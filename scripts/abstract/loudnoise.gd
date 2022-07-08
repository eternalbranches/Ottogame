extends Area2D

var sound_dict := {"small": [], "medium": [], "loud" : []}

func _on_Timer_timeout():
	for body in sound_dict["loud"]:
		if sound_dict["medium"].has(body):
			sound_dict["medium"].erase(body)
		if sound_dict["small"].has(body):
			sound_dict["small"].erase(body)
		if body.is_in_group("Can_Hear"):
			body.heard_sound("loud", get_global_position())
			
	for body in sound_dict["medium"]:
		if sound_dict["small"].has(body):
			sound_dict["small"].erase(body)
		if body.is_in_group("Can_Hear"):
			body.heard_sound("medium", get_global_position())
	
	for body in sound_dict["small"]:
		if body.is_in_group("Can_Hear"):
			body.heard_sound("small", get_global_position())
	queue_free()


func _on_SmallNoise_body_entered(body):
	if sound_dict["small"].has(body) == false:
		sound_dict["small"].push_back(body)


func _on_MediumNoise_body_entered(body):
	if sound_dict["medium"].has(body) == false:
		sound_dict["medium"].push_back(body)


func _on_LoudNoise_body_entered(body):
	if sound_dict["loud"].has(body) == false:
		sound_dict["loud"].push_back(body)
