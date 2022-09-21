extends Control

var volumebus := AudioServer.get_bus_index("Master")
var musicbus := AudioServer.get_bus_index("Music")
var sfxbus := AudioServer.get_bus_index("SFX")
var ambiencebus := AudioServer.get_bus_index("Ambience")
#var weatherbus := AudioServer.get_bus_index("Weather")
var soundvaluearray = {"safedvolumevalue" : 1, "safedmusicvalue" : 1, "safedsfxvalue" : 1, "safedambiencevalue" : 1, "safedweathervalue" : 1}

var clicked := false


func _ready():
	Engine.set_target_fps(60)
	CharacterSave.ingame = false
	load_volume()
	$NinePatchRect/VBoxContainer/PlayButton.grab_focus()

func _on_PlayButton_pressed() -> void:
	if clicked == false:
		clicked = true
		$AnimationPlayer.play("FadeOut")
		$SFXPlayer.play()
		#yield(get_tree().create_timer(0.5), "timeout")
		#get_tree().change_scene("res://Scenes/Interface/Characterselect.tscn")


func _on_OptionsButton_pressed() -> void:
	$NinePatchRect/VBoxContainer.hide()
	$Options.visible = true
	$NinePatchRect.release_focus()
	$Options/TabContainer/SoundOptions/NinePatchRect/VBoxContainer/GameVolumeSlider.grab_focus()
	#get_tree().change_scene("res://Scenes/Interface/Options.tscn")

func _on_CreditsButton_pressed() -> void:
	pass # Replace with function body.



func load_volume() -> void:
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


func _on_AnimationPlayer_animation_finished(_anim_name) -> void:
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/interface/characterselect.tscn")
