extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_BackButton_pressed():
	visible = false
	if CharacterSave.ingame == false:
		get_node("../NinePatchRect/VBoxContainer").visible = true
		get_node("../NinePatchRect/VBoxContainer").show()
		get_node("../NinePatchRect/VBoxContainer/PlayButton").grab_focus()
	else:
		visible = false
		
		get_node("../Pausemenu/HBoxContainer/VBoxContainer/MainMenuButton").grab_focus()
		get_node("../Pausemenu").show()
