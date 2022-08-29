extends Node

export var max_load_time = 10000
func _ready():
	pass

func goto_scene(path, current_scene):
	var loader = ResourceLoader.load_interactive(path)
	
	if loader == null:
		print("Resource loader unable to load the resource at path")
		return
	
	var loading_bar = load("res://scenes/interface/loadingscreen.tscn").instance()
	
	#get_tree().get_root().call_deferred("add_child", loading_bar)
	call_deferred("add_child", loading_bar)
	
	var t = OS.get_ticks_msec()
	
	while OS.get_ticks_msec() - t < max_load_time:
		var err = loader.poll()
		if err == ERR_FILE_EOF:
			#Loading Complete
			var resource = loader.get_resource()
			get_tree().get_root().call_deferred("add_child", resource.instance())
			current_scene.queue_free()
			loading_bar.queue_free()
			break
			
		elif err == OK:
			#still loading
			var progress = float (loader.get_stage())/loader.get_stage_count()
			loading_bar.value = progress * 100
		else: 
			print("Error while loading file")
			break
		yield(get_tree(), "idle_frame")
