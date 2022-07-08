extends KinematicBody2D

func _ready():
	pass
	
func _process(delta):
	$BodyBones/Skeleton2D/Hip/Chest/Head.rotation = get_angle_to(get_global_mouse_position()) -1.4
	
	
