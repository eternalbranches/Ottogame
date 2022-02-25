extends Node
var keybinds = {}
var filepath = "res://keybinds.ini"
var configfile
func _ready():
	configfile = ConfigFile.new()
	if configfile.load(filepath) == OK:
		for key in configfile.get_section_keys("keybinds"):
			var key_value = configfile.get_value("keybinds", key)
			
			if str(key_value) != "":
				keybinds[key] = key_value
			else:
				keybinds[key] = null
	else:
		print("Config file not found")
	set_game_binds()
	

func set_game_binds():
	for key in keybinds.keys():
		var value = keybinds[key]
		
		var actionlist = InputMap.get_action_list(key)
		if !actionlist.empty():
			InputMap.action_erase_event(key, actionlist[0])
			
		if value != null:
			var new_key = InputEventKey.new()
			new_key.set_scancode(value)	
			InputMap.action_add_event(key, new_key)

func write_config():
	for key in keybinds.keys():
		var key_value = keybinds[key]
		if key_value != null:
			configfile.set_value("keybinds", key, key_value)
		else:
			configfile.set_value("keybinds", key, "")
	configfile.save(filepath)
