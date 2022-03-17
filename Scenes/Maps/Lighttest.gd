extends Node2D

var checkpoints = {}
var checkpoint_count := 0

func _ready():
	print($Checkpoints.get_child_count())
	assign_checkpoints()
	checkpoint_load()

func assign_checkpoints():
	while checkpoint_count !=  $Checkpoints.get_child_count():
		$Checkpoints.get_child(checkpoint_count).checkpoint_number = checkpoint_count
		checkpoints[$Checkpoints.get_child(checkpoint_count)] = $Checkpoints.get_child(checkpoint_count).get_global_position()
		print(checkpoints)
		checkpoint_count += 1
		
func checkpoint_load():
	var keys = checkpoints.keys()
	var key  = keys[CharacterSave.save_dict["current_checkpoint"]]
	print("keys:", keys, "key:", key)
	$YSort/Player/Player.global_position = checkpoints[key]
	
	
func music_change(track):
	var music = load(track)
	$MusicPlayer.set_stream(music)
	$MusicPlayer.play()
	
	$Door.visible = true
	$Door.set_collision_layer_bit(0, 1)
	$Door.set_collision_mask_bit(1, 1)
	$Soundtrigger.queue_free()
