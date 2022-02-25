extends Control

var volumebus := AudioServer.get_bus_index("Master")
var musicbus := AudioServer.get_bus_index("Music")
var sfxbus := AudioServer.get_bus_index("SFX")
var weatherbus := AudioServer.get_bus_index("Weather")

#var safedvolumevalue = 1
#var safedmusicvalue = 1
#var safedsoundvalue = 1
#var weathervalue = 1
var soundvaluearray = {"safedvolumevalue" : 1, "safedmusicvalue" : 1, "safedsfxvalue" : 1, "safedweathervalue" : 1}


func _ready():


	#$VolumeSlider.value = db2linear(AudioServer.get_bus_volume_db(volumebus))
	#$MusicSlider.value = db2linear(AudioServer.get_bus_volume_db(musicbus))
	#$SoundeffectSlider.value = db2linear(AudioServer.get_bus_volume_db(effectbus))
	#print(soundvaluearray)
	load_volume()
	
	$NinePatchRect/VBoxContainer/GameVolumeSlider.value = soundvaluearray["safedvolumevalue"]
	$NinePatchRect/VBoxContainer/MusicVolumeSlider.value = soundvaluearray["safedmusicvalue"]
	$NinePatchRect/VBoxContainer/SFXVolumeSlider.value = soundvaluearray["safedsfxvalue"]
	#$NinePatchRect/VBoxContainer/WeatherVolumeSlider.value = soundvaluearray["safedweathervalue"]
	
func _on_GameVolumeSlider_value_changed(value):
	AudioServer.set_bus_volume_db(volumebus, linear2db(value))
	soundvaluearray["safedvolumevalue"] = value
	SaveGameVolumen("safedvolumevalue", value)
func _on_MusicVolumeSlider_value_changed(value):
	AudioServer.set_bus_volume_db(musicbus, linear2db(value))
	soundvaluearray["safedmusicvalue"] = value
	SaveGameVolumen("safedmusicvalue", value)
func _on_SFXVolumeSlider_value_changed(value):
	AudioServer.set_bus_volume_db(sfxbus, linear2db(value))
	soundvaluearray["safedsfxvalue"] = value
	SaveGameVolumen("safedsfxvalue", value)
func _on_WeatherVolumeSlider_value_changed(value):
	AudioServer.set_bus_volume_db(weatherbus, linear2db(value))
	soundvaluearray["safedweathervalue"] = value
	SaveGameVolumen("safedweathervalue", value)



func SaveGameVolumen(volumentype, value):
	var volumefile = File.new()
	volumefile.open("user://save_volume.dat", File.WRITE)
	volumefile.store_var(soundvaluearray)
	volumefile.close()
	

func load_volume():
	var volumefile = File.new()
	if volumefile.file_exists("user://save_volume.dat"):
		volumefile.open("user://save_volume.dat", File.READ)
		#print(volumefile.result)
		soundvaluearray = volumefile.get_var()
		volumefile.close()


func _on_BackButton_pressed():
	get_tree().change_scene("res://Scenes/Interface/Mainscreen.tscn")
