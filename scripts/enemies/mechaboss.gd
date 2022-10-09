extends KinematicBody2D

var direction = "L"
var gun_speed = 1 
var elapsed = 1.0
onready var gun = $Sprite/Skeleton2D/Shoulder/Gun/Gunlow/Gun
func _ready():
	pass 
	
	
func _process(delta):
	$Position2D.global_position = get_global_mouse_position()
	#$"%Particles2D".global_position = $Sprite/Skeleton2D/Shoulder/Nuzzle.global_position
	
	
#	var min_angle = deg2rad(0.0)
#	var max_angle = deg2rad(90.0)
#	gun.rotation = lerp_angle(min_angle, max_angle, elapsed)
#	elapsed += delta
	
func _physics_process(delta):
	pass
	
	  

	#lerp_angle()
	#gun.rotation = get_angle_to(get_global_mouse_position()) -1.2
#	if gun.position.x > $Position2D.position.x:
#		gun.position.x += gun_speed
	
#	if gun.position.y > $Position2D.position.y:
	#	gun.position.y += gun_speed
	#'$BodyBones/Skeleton2D/Hip/Chest/Head.rotation = get_angle_to(get_global_mouse_position()) -1.4'
	
#func aim_at_target():
	#gun.rotation = lerp(gun.rotation, get_angle_to(get_global_mouse_position()) -1.2, 4)
#	gun.rotation = 


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"aim_L":
			$AnimationPlayer.play("stop_aim_L")
		"stop_aim_L":
			$AnimationPlayer.play("idle_L")
		"idle_L":
			$AnimationPlayer.play("aim_L")
