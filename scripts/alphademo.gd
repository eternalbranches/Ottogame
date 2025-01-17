extends Node2D
var checkpoints = {}
var checkpoint_count := 0


func _ready():
	assign_checkpoints()
	checkpoint_load()
	if CharacterSave.first_spawn == false:
		respawn_animation()


func _process(_delta):
	if Input.is_action_just_pressed("ESC"):
		$GUI/Pausemenu.visible = true
		$GUI/Pausemenu/HBoxContainer/VBoxContainer/MainMenuButton.grab_focus()
		get_tree().paused = true
		
func assign_checkpoints():
	while checkpoint_count !=  $YSort/Checkpoints.get_child_count():
		$YSort/Checkpoints.get_child(checkpoint_count).checkpoint_number = checkpoint_count
		checkpoints[$YSort/Checkpoints.get_child(checkpoint_count)] = $YSort/Checkpoints.get_child(checkpoint_count).get_global_position()
		checkpoint_count += 1
		
func checkpoint_load():
	var keys = checkpoints.keys()
	var key  = keys[CharacterSave.save_dict["current_checkpoint"]]
	$YSort/Player/Player.global_position = checkpoints[key]
	
	
func music_change(track):
	var music = load(track)
	$MusicPlayer.set_stream(music)
	$MusicPlayer.play()
	
	$Door.visible = true
	$Door.set_collision_layer_bit(0, 1)
	$Door.set_collision_mask_bit(1, 1)
	$Soundtrigger.queue_free()


func _on_Player_death():
	CharacterSave.first_spawn = false
	yield(get_tree().create_timer(1), "timeout")
	$CanvasModulate.color = Color(0,0,0)
	#var savefile = File.new()
	#savefile.open("user://save_file"+ CharacterSave.save_dict["character_name"]+".dat", File.READ)
	#CharacterSave.save_dict = savefile.get_var()
	#savefile.close()
	yield(get_tree().create_timer(1.5), "timeout")
	get_tree().reload_current_scene()
	#var keys = checkpoints.keys()
	#var key  = keys[CharacterSave.save_dict["current_checkpoint"]]
	#$YSort/Player/Player.global_position = checkpoints[key]
	#$CanvasModulate.color = Color(0.27,0.27,0.27)
	


func _on_Cameratrigger_body_entered(_body):
	$Camera2D.current = true


func _on_Cameratrigger_body_exited(_body):
	$YSort/Player/Player/Camera2D.current = true
	
func respawn_animation():
	var keys = checkpoints.keys()
	var key  = keys[CharacterSave.save_dict["current_checkpoint"]]
	$YSort/Player/Mothgirl.global_position = checkpoints[key] - Vector2 (40, 15)
	$YSort/Player/Mothgirl.heal_animation()
	yield(get_tree().create_timer(3), "timeout")
	$YSort/Player/Mothgirl.stop_flying()
	$YSort/Player/Mothgirl.position = Vector2(3700,500)




func _on_MainMenuButton_pressed():
	$GUI/Pausemenu/Popup.visible = true
	$GUI/Pausemenu/Popup/VBoxContainer/HBoxContainer/NoButton.grab_focus()
	
func _on_YesButton_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://Scenes/Interface/Mainscreen.tscn")

func _on_NoButton_pressed():
	$GUI/Pausemenu/Popup.visible = false
	$GUI/Pausemenu.grab_focus()
	
func _on_BackButton_pressed():
	$GUI/Pausemenu.visible = false
	$GUI/Pausemenu/Popup.visible = false
	get_tree().paused = false

func _on_OptionsButton_pressed():
	$GUI/Options.visible = true
	$GUI/Pausemenu.hide()
	$GUI/Options/TabContainer/SoundOptions/NinePatchRect/VBoxContainer/GameVolumeSlider.grab_focus()
