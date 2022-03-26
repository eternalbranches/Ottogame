extends Control

var selected_tab := 0
var tab_count := 0
func _ready():
	tab_count = $TabContainer.get_tab_count()

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

func _process(delta):
	if Input.is_action_just_pressed("NextTab"):
		print(selected_tab, tab_count)
		selected_tab += 1
		if selected_tab > tab_count -1:
			selected_tab = 0
		$TabContainer.current_tab = selected_tab
		$BackButton.grab_focus()
	if Input.is_action_just_pressed("LastTab"):
		selected_tab -= 1
		if selected_tab < 0 :
			selected_tab = tab_count -1
		$TabContainer.current_tab = selected_tab
		$BackButton.grab_focus()
