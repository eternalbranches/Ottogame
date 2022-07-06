extends Control

func _ready():
	Scenechanger.goto_scene("res://scenes/maps/"+CharacterSave.save_dict["current_map"]+".tscn", self)
