extends Control
var ironman := false
var delete_array = []
var charslot_dict = {"Charslot1": ["empty", "empty"], "Charslot2" : ["empty", "empty"], "Charslot3" : ["empty", "empty"] }
var progress_dict = {}
var pressed_loading := false

const ironman_texture = preload("res://icon.png")
const bunny_texture = preload("res://icon.png")
func _ready():
	LoadSlots()

func SaveSlots():
	var savefile = File.new()
	savefile.open("user://gamedata.dat", File.WRITE)
	savefile.store_var(charslot_dict)
	savefile.close()

func LoadSlots():
	var savefile = File.new()
	if savefile.file_exists("user://gamedata.dat"):
		savefile.open("user://gamedata.dat", File.READ)
		charslot_dict = savefile.get_var()
		savefile.close()
		CharacterSlots()
	else:
		savefile.open("user://gamedata.dat", File.WRITE)
		savefile.store_var(charslot_dict)
		savefile.close()
		
		
func _on_IronmanMode_toggled(button_pressed):
	if button_pressed:
		ironman = true
		get_node("N/H1/IronmanMode/PlayChar1").texture_normal = ironman_texture
		get_node("N/H2/IronmanMode/PlayChar2").texture_normal = ironman_texture
		get_node("N/H3/IronmanMode/PlayChar3").texture_normal = ironman_texture
	else:
		ironman = false
		get_node("N/H1/IronmanMode/PlayChar1").texture_normal = bunny_texture
		get_node("N/H2/IronmanMode/PlayChar2").texture_normal = bunny_texture
		get_node("N/H3/IronmanMode/PlayChar3").texture_normal = bunny_texture
		
func _on_LineEdit_text_entered(new_text):
	var counter = 1
	var savefile = File.new()
	for character in charslot_dict:
		if charslot_dict[character][0] == "empty" and new_text != "empty":
			#savefile.open("user://save_file"+ new_text +".dat", File.WRITE)
			#savefile.store_var(CharacterSave.save_dict)
			charslot_dict[character][0] = new_text
			if ironman == true:
				charslot_dict[character][1] = "true"
			else:
				charslot_dict[character][1] = "false"
			CharacterSlots()
			counter += 1
			SaveSlots()
			break
	
	
func CharacterSlots():
	var slot = 1
	for character in charslot_dict:
		match character:
			"Charslot1":
					slot = 1
			"Charslot2":
					slot = 2
			"Charslot3":
					slot = 3
		if charslot_dict[character][1] != "empty":
			get_node("N/H"+ str(slot) +"/Charactername").text = charslot_dict[character][0]
			get_node("N/H"+ str(slot) +"/Label").text =  "   Play ->"
			get_node("N/H"+ str(slot) +"/Delete"+str(slot)).visible = true
			get_node("N/H"+ str(slot) +"/IronmanMode").visible = true
			#if charslot_dict[character][1] == "true":
				#get_node("N/H"+ str(slot) +"/IronmanMode/IronmanTexture").texture = ironman_texture
			#elif charslot_dict[character][1] == "false":
			#	get_node("N/H"+ str(slot) +"/IronmanMode/IronmanTexture").texture = bunny_texture
			#slot += 1
		else:
			get_node("N/H"+ str(slot) +"/Delete"+str(slot)).visible = false
			get_node("N/H"+ str(slot) +"/IronmanMode").visible = false
			
func _on_PlayChar1_pressed():
	if pressed_loading == false:
		pressed_loading = true
		if charslot_dict["Charslot1"][0] != "empty":
			var savefile = File.new()
		
			if savefile.file_exists("user://save_file"+ charslot_dict["Charslot1"][0] +".dat"):
				savefile.open("user://save_file"+ charslot_dict["Charslot1"][0] +".dat", File.READ)
				progress_dict = savefile.get_var()
				CharacterSave.load_progress(progress_dict)
				savefile.close()
				$SFXStreamPlayer.play()
				yield(get_tree().create_timer(0.5), "timeout")
				get_tree().change_scene("res://Scenes/Maps/Lighttest.tscn")
			else:
				savefile.open("user://save_file"+ charslot_dict["Charslot1"][0] +".dat", File.WRITE)
				savefile.close()
				CharacterSave.save_dict["character_name"] = charslot_dict["Charslot1"][0]
				CharacterSave.save_dict["ironman"] = charslot_dict["Charslot1"][1]
				CharacterSave.save_progress()
				$SFXStreamPlayer.play()
				yield(get_tree().create_timer(0.5), "timeout")
				get_tree().change_scene("res://Scenes/Maps/Lighttest.tscn")


func _on_PlayChar2_pressed():
	if pressed_loading == false:
		pressed_loading = true
		if charslot_dict["Charslot2"][0] != "empty":
			var savefile = File.new()
			if savefile.file_exists("user://save_file"+ charslot_dict["Charslot2"][0] +".dat"):
				savefile.open("user://save_file"+ charslot_dict["Charslot2"][0] +".dat", File.READ)
				progress_dict = savefile.get_var()
				CharacterSave.load_progress(progress_dict)
				savefile.close()
				$SFXStreamPlayer.play()
				yield(get_tree().create_timer(0.5), "timeout")
				get_tree().change_scene("res://Scenes/Maps/Lighttest.tscn")
			else:
				savefile.open("user://save_file"+ charslot_dict["Charslot2"][0] +".dat", File.WRITE)
				savefile.close()
				CharacterSave.save_dict["character_name"] = charslot_dict["Charslot2"][0]
				CharacterSave.save_dict["ironman"] = charslot_dict["Charslot2"][1]
				CharacterSave.save_progress()
				$SFXStreamPlayer.play()
				yield(get_tree().create_timer(0.5), "timeout")
				get_tree().change_scene("res://Scenes/Maps/Lighttest.tscn")

func _on_PlayChar3_pressed():
	if pressed_loading == false:
		pressed_loading = true
		if charslot_dict["Charslot3"][0] != "empty":
			var savefile = File.new()
			if savefile.file_exists("user://save_file"+ charslot_dict["Charslot3"][0] +".dat"):
				savefile.open("user://save_file"+ charslot_dict["Charslot3"][0] +".dat", File.READ)
				progress_dict = savefile.get_var()
				CharacterSave.load_progress(progress_dict)
				savefile.close()
				$SFXStreamPlayer.play()
				yield(get_tree().create_timer(0.5), "timeout")
				get_tree().change_scene("res://Scenes/Maps/Lighttest.tscn")
			else:
				savefile.open("user://save_file"+ charslot_dict["Charslot3"][0] +".dat", File.WRITE)
				savefile.close()
				CharacterSave.save_dict["character_name"] = charslot_dict["Charslot3"][0]
				CharacterSave.save_dict["ironman"] = charslot_dict["Charslot3"][1]
				CharacterSave.save_progress()
				$SFXStreamPlayer.play()
				yield(get_tree().create_timer(0.5), "timeout")
				get_tree().change_scene("res://Scenes/Maps/Lighttest.tscn")
			
			
func _on_ConfirmDelete_pressed():
	var dir = Directory.new()
	dir.remove("user://save_file"+ delete_array[0] +".dat")
	charslot_dict[delete_array[1]] = ["empty", "empty"]
	$N/Popup.visible = false
	SaveSlots()
	
	if delete_array[1] == "Charslot1":
		get_node("N/H1/Charactername").text = "                                   -  Empty Characterslot    -"
		get_node("N/H1/IronmanMode/IronmanTexture").texture = null
		get_node("N/H1/Label").text = ""
		get_node("N/H1/Delete1").visible = false
		get_node("N/H1/IronmanMode").visible = false
	if delete_array[1] == "Charslot2":
		get_node("N/H2/Charactername").text = "                                   -  Empty Characterslot    -"
		get_node("N/H2/IronmanMode/IronmanTexture").texture = null
		get_node("N/H2/Label").text = ""
		get_node("N/H2/Delete2").visible = false
		get_node("N/H2/IronmanMode").visible = false
	if delete_array[1] == "Charslot3":
		get_node("N/H3/Charactername").text = "                                   -  Empty Characterslot    -"
		get_node("N/H3/IronmanMode/IronmanTexture").texture = null
		get_node("N/H3/Label").text = ""
		get_node("N/H3/Delete3").visible = false
		get_node("N/H3/IronmanMode").visible = false


func _on_StopDelete_pressed():
	$N/Popup.visible = false


func _on_Delete1_pressed():
	$N/Popup/TextureRect/charname.text = charslot_dict["Charslot1"][0]
	$N/Popup.visible = true
	delete_array = [charslot_dict["Charslot1"][0], "Charslot1"]

func _on_Delete2_pressed():
	$N/Popup/TextureRect/charname.text = charslot_dict["Charslot2"][0]
	$N/Popup.visible = true
	delete_array = [charslot_dict["Charslot2"][0], "Charslot2"]

func _on_Delete3_pressed():
	$N/Popup/TextureRect/charname.text = charslot_dict["Charslot3"][0]
	$N/Popup.visible = true
	delete_array = [charslot_dict["Charslot3"][0], "Charslot3"]





func _on_BackButton_pressed():
	get_tree().change_scene("res://scenes/MainMenu.tscn")
