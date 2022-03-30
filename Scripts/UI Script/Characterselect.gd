extends Control
var progress_dict1 := {"ironman" : false, "current_checkpoint" : 0, 
					"walljump": false, "doublejump": false, "gun" : false, "flashlight": false, "timeslow": false, "crawling": false, "running": false,
					"orange_keycard": false}
var progress_dict2 := {"ironman" : false, "current_checkpoint" : 0, 
					"walljump": false, "doublejump": false, "gun" : false, "flashlight": false, "timeslow": false, "crawling": false, "running": false,
					"orange_keycard": false}
var progress_dict3 := {"ironman" : false, "current_checkpoint" : 0, 
					"walljump": false, "doublejump": false, "gun" : false, "flashlight": false, "timeslow": false, "crawling": false, "running": false,
					"orange_keycard": false}

var delet_save:= "1"
var PressedLoading := false

func _ready():
	$AnimationPlayer.play("FadeIn")
	$N/H1/PlayChar1.grab_focus()
	progress_load()
		
func progress_load():
	var savefile = File.new()
	if savefile.file_exists("user://save_file1.dat"):
		$N/H1/PlayChar1/Charactername.text = "Profile 1"
		$N/H1/Delete1.visible = true
	else:
		$N/H1/PlayChar1/Charactername.text = "-empty-"
		$N/H1/Delete1.visible = false
	if savefile.file_exists("user://save_file2.dat"):
		$N/H2/PlayChar2/Charactername.text = "Profile 2"
		$N/H2/Delete2.visible = true
	else:
		$N/H2/PlayChar2/Charactername.text = "-empty-"
		$N/H2/Delete2.visible = false
	if savefile.file_exists("user://save_file3.dat"):
		$N/H3/PlayChar3/Charactername.text = "Profile 3"
		$N/H3/Delete3.visible = true
	else:
		$N/H3/PlayChar3/Charactername.text = "-empty-"
		$N/H3/Delete3.visible = false

	
func _on_PlayChar1_pressed():
	var savefile = File.new()
	if savefile.file_exists("user://save_file1.dat"):
		if PressedLoading == false:
			PressedLoading = true
			CharacterSave.profile = 1
			savefile.open("user://save_file1.dat", File.READ)
			CharacterSave.load_progress(savefile.get_var())
			savefile.close()
			$SFXStreamPlayer.play()
			$N/H1/PlayChar1.texture_focused = load("res://Assets/UI/Buttons/Button_Clicked.png")
			$AnimationPlayer.play("FadeOut")
			#yield(get_tree().create_timer(0.5), "timeout")
			#get_tree().change_scene("res://Scenes/Maps/Lighttest.tscn")
	else:
		var savefile1 = File.new()
		savefile1.open("user://save_file1.dat", File.WRITE)
		savefile1.store_var(progress_dict1)
		savefile1.close()
		progress_load()

func _on_PlayChar2_pressed():
	var savefile = File.new()
	if savefile.file_exists("user://save_file2.dat"):
		if PressedLoading == false:
			PressedLoading = true
			CharacterSave.profile = 2
			savefile.open("user://save_file2.dat", File.READ)
			CharacterSave.load_progress(savefile.get_var())
			savefile.close()
			$SFXStreamPlayer.play()
			$N/H2/PlayChar2.texture_focused = load("res://Assets/UI/Buttons/Button_Clicked.png")
			#yield(get_tree().create_timer(0.5), "timeout")
			#get_tree().change_scene("res://Scenes/Maps/Lighttest.tscn")
	else:
		savefile.open("user://save_file2.dat", File.WRITE)
		savefile.store_var(progress_dict2)
		savefile.close()
		progress_load()

func _on_PlayChar3_pressed():
	var savefile = File.new()
	if savefile.file_exists("user://save_file3.dat"):
		if PressedLoading == false:
			PressedLoading = true
			CharacterSave.profile = 3
			savefile.open("user://save_file3.dat", File.READ)
			CharacterSave.load_progress(savefile.get_var())
			savefile.close()
			$SFXStreamPlayer.play()
			$N/H3/PlayChar3.texture_focused = load("res://Assets/UI/Buttons/Button_Clicked.png")
			#yield(get_tree().create_timer(0.5), "timeout")
			#get_tree().change_scene("res://Scenes/Maps/Lighttest.tscn")
	else:
		savefile.open("user://save_file3.dat", File.WRITE)
		savefile.store_var(progress_dict3)
		savefile.close()
		progress_load()
func _on_Delete1_pressed():
	$N/Popup.visible = true
	$N/Popup/TextureRect/StopDelete.grab_focus()
	delet_save = "1"
	
func _on_Delete2_pressed():
	$N/Popup.visible = true
	$N/Popup/TextureRect/StopDelete.grab_focus()
	delet_save = "2"


func _on_Delete3_pressed():
	$N/Popup.visible = true
	$N/Popup/TextureRect/StopDelete.grab_focus()
	delet_save = "3"


func _on_PlayChar1_mouse_entered():
	if PressedLoading == false:
		$N/H1/PlayChar1.grab_focus()


func _on_PlayChar2_mouse_entered():
	if PressedLoading == false:
		$N/H2/PlayChar2.grab_focus()


func _on_PlayChar3_mouse_entered():
	if PressedLoading == false:
		$N/H3/PlayChar3.grab_focus()


func _on_ConfirmDelete_pressed():
	$N/Popup.visible = false
	var dir = Directory.new()
	dir.remove("user://save_file"+ delet_save +".dat")
	progress_load()

	


func _on_StopDelete_pressed():
	$N/Popup.visible = false
	$N/H1/PlayChar1.grab_focus()



func _on_BackButton_pressed():
	get_tree().change_scene("res://Scenes/Interface/Mainscreen.tscn")


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"FadeIn":
			$AnimationPlayer.play("Background_Animation")
		"FadeOut":
			get_tree().change_scene("res://Scenes/Maps/Lighttest.tscn")
