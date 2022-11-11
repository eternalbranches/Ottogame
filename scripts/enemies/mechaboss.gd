extends KinematicBody2D

var direction := "L"
var gun_speed := 1 
var elapsed := 1.0
var state := "idle"
var invulnerable := false
var current_hp := 300
var velocity := Vector2.ZERO
var dead := false






onready var gun = $Sprite/Skeleton2D/Shoulder/Gun/Gunlow/Gun
func _ready():
	pass 
	
	
func _process(_delta):
	$Position2D.global_position = get_global_mouse_position()
	#$"%Particles2D".global_position = $Sprite/Skeleton2D/Shoulder/Nuzzle.global_position
	
	
#	var min_angle = deg2rad(0.0)
#	var max_angle = deg2rad(90.0)
#	gun.rotation = lerp_angle(min_angle, max_angle, elapsed)
#	elapsed += delta
	
func _physics_process(_delta):
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



func on_hit(damage : float, _origin : String, enemy_pos : Vector2, knockback : Vector2) -> void:
	if state != "death" or invulnerable == false:
		current_hp -= damage
	if position.x < enemy_pos.x:
		velocity.x = knockback.x
	else:
		velocity.x = -knockback.x
	if position.y < enemy_pos.x:
		velocity.y = knockback.y
	else:
		velocity.y = -knockback.y
	if current_hp <= 0:
		on_death()
	flash()
	
	
func on_death() -> void:
	change_state("death")
	dead = true
	
	
func change_state(new_state : String) -> void:
	#print( state, new_state)
	if state != "death":
		state = new_state
		
	
func flash():
	$Sprite.material.set_shader_param("flash_modifier", 0.4)
	$FlashTimer.start()

func _on_FlashTimer_timeout() -> void:
	$Sprite.material.set_shader_param("flash_modifier", 0)

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"aim_L":
			$AnimationPlayer.play("stop_aim_L")
		"stop_aim_L":
			$AnimationPlayer.play("idle_L")
		"idle_L":
			$AnimationPlayer.play("aim_L")
