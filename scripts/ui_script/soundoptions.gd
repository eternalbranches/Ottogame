extends Control

var volumebus := AudioServer.get_bus_index("Master")
var musicbus := AudioServer.get_bus_index("Music")
var sfxbus := AudioServer.get_bus_index("SFX")
var ambiencebus := AudioServer.get_bus_index("Ambience")
var weatherbus := AudioServer.get_bus_index("Weather")

var soundvaluearray = {"safedvolumevalue" : 1, "safedmusicvalue" : 1, "safedsfxvalue" : 1,  "safedambiencevalue": 1, "safedweathervalue" : 1}


func _ready():
	#$NinePatchRect/VBoxContainer/GameVolumeSlider.grab_focus()
	#$VolumeSlider.value = db2linear(AudioServer.get_bus_volume_db(volumebus))
	#$MusicSlider.value = db2linear(AudioServer.get_bus_volume_db(musicbus))
	#$SoundeffectSlider.value = db2linear(AudioServer.get_bus_volume_db(effectbus))
	#print(soundvaluearray)
	load_volume()
	
	$NinePatchRect/VBoxContainer/GameVolumeSlider.value = soundvaluearray["safedvolumevalue"]
	$NinePatchRect/VBoxContainer/MusicVolumeSlider.value = soundvaluearray["safedmusicvalue"]
	$NinePatchRect/VBoxContainer/SFXVolumeSlider.value = soundvaluearray["safedsfxvalue"]
	$NinePatchRect/VBoxContainer/Ambiencevolumeslider.value = soundvaluearray["safedambiencevalue"]
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
func _on_Ambiencevolumeslider_changed(value):
	AudioServer.set_bus_volume_db(ambiencebus, linear2db(value))
	soundvaluearray["safedambiencevalue"] = value
	SaveGameVolumen("safedambiencevalue", value)
func _on_WeatherVolumeSlider_value_changed(value):
	AudioServer.set_bus_volume_db(weatherbus, linear2db(value))
	soundvaluearray["safedweathervalue"] = value
	SaveGameVolumen("safedweathervalue", value)


func SaveGameVolumen(_volumentype, _value):
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
