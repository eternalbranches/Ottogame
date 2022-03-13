extends Node

var character_name := ""
var current_checkpoint := 0
var ironman := true


func save_progress():
	var save_dict = {"character_name" : character_name, "ironman" : ironman, "current_checkpoint" : current_checkpoint}
	var savefile = File.new()
	savefile.open("user://save_file"+ character_name +".dat", File.WRITE)
	savefile.store_var(save_dict)
	savefile.close()
	
	
func load_progress(loadeddata):
	character_name = loadeddata["character_name"]
	ironman = loadeddata["ironman"]
	#level
	current_checkpoint = loadeddata["current_checkpoint"]
	
	
func delete_save():
	current_checkpoint = 0
	save_progress()
