extends CanvasLayer

func _process(_delta):
	if $Pausemenu.visible == true:
		if Input.is_action_just_pressed("ESC"):
			_on_BackButton_pressed()
	else:
		if Input.is_action_just_pressed("ESC"):
			$Pausemenu.visible = true
			$Pausemenu/HBoxContainer/VBoxContainer/MainMenuButton.grab_focus()
			get_tree().paused = true
func _on_MainMenuButton_pressed():
	$Pausemenu/Popup.visible = true
	$Pausemenu/Popup/VBoxContainer/HBoxContainer/NoButton.grab_focus()
	
func _on_YesButton_pressed() -> void:
	get_tree().paused = false
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Scenes/Interface/Mainscreen.tscn")

func _on_NoButton_pressed() -> void:
	$Pausemenu/Popup.visible = false
	$Pausemenu.grab_focus()
	
func _on_BackButton_pressed() -> void:
	$Pausemenu.visible = false
	$Pausemenu/Popup.visible = false
	get_tree().paused = false

func _on_OptionsButton_pressed() -> void:
	$Options.visible = true
	$Pausemenu.hide()
	$Options/TabContainer/SoundOptions/NinePatchRect/VBoxContainer/GameVolumeSlider.grab_focus()
