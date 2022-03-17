extends Area2D

export var play_music = "res://Assets/Soundtrack/Music/Modern Battle Theme 5.ogg"
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Soundtrigger_body_entered(body):
	get_node("..").music_change(play_music)
	#get_parent().music_change(play_music)
