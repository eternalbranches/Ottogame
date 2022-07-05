extends Control
onready var buttoncontainer = get_node("N/P/V")
onready var buttonscript = load("res://scenes/UI/KeyButton.gd")

var keybinds
var buttons = {}

func _ready():
	keybinds = DataImport.keybinds.duplicate()
	for key in keybinds.keys():
		var hbox = HBoxContainer.new()
		var label = Label.new()
		var button = Button.new()
		
		hbox.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		label.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		button.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		
		label.text = key
		
		var button_value = keybinds[key]
		
		if button_value != null:
			button.text = OS.get_scancode_string(button_value)
		else:
			button.text = "Unassigned"
		
		button.set_script(buttonscript)
		button.key = key
		button.value = button_value
		button.menu = self
		button.toggle_mode = true
		button.focus_mode = Control.FOCUS_NONE
		label.add_font_override("font", load("res://assets/UI/Small_font.tres"))
		label.align = Label.ALIGN_CENTER
		button.add_font_override("font", load("res://assets/UI/Small_font.tres"))
		
		
		hbox.add_child(label)
		hbox.add_child(button)
		buttoncontainer.add_child(hbox)
		
		buttons[key] = button


func change_bind(key, value):
	keybinds[key] = value
	for k in keybinds.keys():
		if k != key and value != null and keybinds[k] == value:
			keybinds[k]= null
			buttons[k].value = null
			buttons[k].text = "Unassigned"


func _on_save_pressed():
	DataImport.keybinds = keybinds.duplicate()
	DataImport.set_game_binds()
	DataImport.write_config()

	
func _on_back_pressed():
	get_tree().change_scene("res://scenes/MainMenu.tscn")
