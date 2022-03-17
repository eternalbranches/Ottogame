extends Node

var save_dict = {"character_name" : "character_name", "ironman" : false, "current_checkpoint" : 0, 
					"walljump": false, "doublejump": false, "gun" : false, "flashlight": false, "timeslow": false, "crawling": false, "running": false,
					"orange_keycard": false}


func save_progress():
	var savefile = File.new()
	savefile.open("user://save_file"+ save_dict["character_name"] +".dat", File.WRITE)
	savefile.store_var(save_dict)
	savefile.close()
	
	
func load_progress(loadeddata):
	print(loadeddata)
	save_dict = loadeddata
	
	
func delete_save():
	save_dict = {"character_name" : save_dict["character_name"], "ironman" : false, "current_checkpoint" : 0, 
					"walljump": false, "doublejump": false, "gun" : false, "flashlight": false, "timeslow": false, "crawling": false, "running": false}
	save_progress()
