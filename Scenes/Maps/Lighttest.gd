extends Node2D

var checkpoints = {}
var checkpoint_count := 0


func _ready():
	$AnimationPlayer.play("FadeIn")
	assign_checkpoints()
	checkpoint_load()
	if CharacterSave.first_spawn == false:
		respawn_animation()
	print(CharacterSave.save_dict["keycards"])


func _process(_delta):
	pass
		
		
func assign_checkpoints() -> void:
	while checkpoint_count !=  $Checkpoints.get_child_count():
		$Checkpoints.get_child(checkpoint_count).checkpoint_number = checkpoint_count
		checkpoints[$Checkpoints.get_child(checkpoint_count)] = $Checkpoints.get_child(checkpoint_count).get_global_position()
		checkpoint_count += 1
		
func checkpoint_load() -> void:
	var keys = checkpoints.keys()
	var key  = keys[CharacterSave.save_dict["current_checkpoint"]]
	$YSort/Player/Player.global_position = checkpoints[key]
	
	
func music_change(track) -> void:
	var music = load(track)
	$MusicPlayer.set_stream(music)
	$MusicPlayer.play()
	
	$Door.visible = true
	$Door.set_collision_layer_bit(0, 1)
	$Door.set_collision_mask_bit(1, 1)
	$Soundtrigger.queue_free()


func _on_Player_death() -> void:
	CharacterSave.first_spawn = false
	yield(get_tree().create_timer(1), "timeout")
	$CanvasModulate.color = Color(0,0,0)
	get_tree().set_current_scene(self)
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
	


func _on_Cameratrigger_body_entered(_body) -> void:
	$Camera2D.current = true


func _on_Cameratrigger_body_exited(_body) -> void:
	$YSort/Player/Player/Camera2D.current = true
	
func respawn_animation() -> void:
	var keys = checkpoints.keys()
	var key  = keys[CharacterSave.save_dict["current_checkpoint"]]
	$YSort/Player/Mothgirl.global_position = checkpoints[key] - Vector2 (40, 15)
	$YSort/Player/Mothgirl.heal_animation()
	yield(get_tree().create_timer(3), "timeout")
	$YSort/Player/Mothgirl.stop_flying()
	$YSort/Player/Mothgirl.position = Vector2(3700,500)
