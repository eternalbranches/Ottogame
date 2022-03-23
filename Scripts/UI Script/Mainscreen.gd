extends Control

var volumebus := AudioServer.get_bus_index("Master")
var musicbus := AudioServer.get_bus_index("Music")
var sfxbus := AudioServer.get_bus_index("SFX")
var ambiencebus := AudioServer.get_bus_index("Ambience")
#var weatherbus := AudioServer.get_bus_index("Weather")
var soundvaluearray = {"safedvolumevalue" : 1, "safedmusicvalue" : 1, "safedsfxvalue" : 1, "safedambiencevalue" : 1, "safedweathervalue" : 1}


func _ready():
	CharacterSave.ingame = false
	load_volume()

func _on_PlayButton_pressed():
	get_tree().change_scene("res://Scenes/Interface/Characterselect.tscn")


func _on_OptionsButton_pressed():
	get_tree().change_scene("res://Scenes/Interface/Options.tscn")

func _on_CreditsButton_pressed():
	pass # Replace with function body.



func load_volume():
	var volumefile = File.new()
	if volumefile.file_exists("user://save_volume.dat"):
		volumefile.open("user://save_volume.dat", File.READ)
		#print(volumefile.result)
		soundvaluearray = volumefile.get_var()
		volumefile.close()
		
	AudioServer.set_bus_volume_db(volumebus, linear2db(soundvaluearray["safedvolumevalue"]))
	AudioServer.set_bus_volume_db(musicbus, linear2db(soundvaluearray["safedmusicvalue"]))
	AudioServer.set_bus_volume_db(sfxbus, linear2db(soundvaluearray["safedsfxvalue"]))
	AudioServer.set_bus_volume_db(ambiencebus, linear2db(soundvaluearray["safedambiencevalue"]))
