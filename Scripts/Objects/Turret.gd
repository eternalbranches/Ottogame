extends StaticBody2D
onready var player = get_node("../../Player/Player")

var current_target
var can_shoot := true
var laser_active := false
var current_hp := 20
var laser_speed := 1
var can_activate := true
var current_direction := "W"
export var black := false

var state = "idle"
var initialized := false
export var sprite_pointing := "S"

func _ready():
	if black == true:
		$Sprite/Tower.texture = load("res://Assets/Objects/turretnewlcolor_spritesheet.png")
	$AnimationPlayer.play("Inactive")
	#match sprite_pointing:
	#	"S":
	#		pass
	#	"N":
	#		$Sprite.flip_v = false
	#	"E":
	#		$Sprite.rotation_degrees = -90
	#	"W":
	#		$Sprite.rotation_degrees = 90

func _process(_delta):
	$Label.text = state
	match state:
		"idle":
			pass
		"sight":
			pass
			#sightcheck()
		"shoot":
			#sightcheck()
			if initialized == false:
				$ShootCD.start()
				initialized = true
			if can_shoot == true:
				var skill = load("res://Scenes/Abilities/Bullet.tscn")
				var skill_instance = skill.instance()
				skill_instance.rotation = get_angle_to(player.get_global_position())
				skill_instance.position = get_position()                   #get_node("TurnAxis/CastPoint").get_global_position()
				skill_instance.enemyposx = position.x
				skill_instance.origin = "Enemy"
				#skill_instance.node_reference = get_path()
				#$SFXPLayer.play()
				get_parent().add_child(skill_instance)
				can_shoot = false
		"laser":
			if can_shoot == true and current_target.get_global_position().y > get_global_position().y:
				if current_target.get_global_position().x > get_global_position().x:
					current_direction = "E"
				else:
					current_direction = "W"
				can_shoot = false
				if laser_active == false:
					laser_active = true
					if current_direction == "E":
						$Laser.rotation_degrees = rad2deg(get_angle_to(current_target.get_global_position())+ 45)
					else:
						$Laser.rotation_degrees = rad2deg(get_angle_to(current_target.get_global_position())- 45)
					$Laser.set_is_casting(true)
					if $LaserTimer.is_stopped():
						$LaserTimer.start()
					
			if laser_active == true:
				if current_direction == "E":
					$Laser.rotation_degrees -= laser_speed
					#if $Laser.rotation_degrees > rad2deg(get_angle_to(current_target.get_global_position()) -45):
					#	laser_active == false
				else:
					$Laser.rotation_degrees += laser_speed
					#if $Laser.rotation_degrees > rad2deg(get_angle_to(current_target.get_global_position()) +45):
					#	laser_active == false
						
						
					
					
				#if current_target.get_global_position() > get_global_position():
				#	$AnimationPlayer.play("Attack_E")
				#else:
				#	$AnimationPlayer.play("Attack_W")
	
func sightcheck():
	#var raycasting_player = player.position - Vector2(0, 0)
	var space_state = get_world_2d().direct_space_state
	var sight_check = space_state.intersect_ray(position, player.position, [self], collision_mask)
	if sight_check:
		#print(sight_check)
		if sight_check.collider.name == "Player":
			if state != "shoot":
				change_states("shoot", "sightcheck")
		else:
			initialized = false
			change_states("sight", "sightcheck")
			$ShootCD.stop()

func _on_Range_body_entered(body):
	if state == "idle" and can_activate == true:
		current_target = body
		can_activate = false
		$AnimationPlayer.play("Activate")
		$SFXPLayer.play()
	elif state == "idle" and can_activate == false:
		state = "laser"


func _on_Range_body_exited(_body):
	if can_activate == true:
		if state == "laser":
			initialized = false
			if state != "death":
				change_states("idle", "range_body_exited")
			#$ShootCD.stop()
			$AnimationPlayer.play("Deactivate")
			#$Deactivate.start()
	else:
		$ChangeState.start()
		
func _on_ChangeState_timeout():
	if $Range.get_overlapping_bodies().empty():
		if state != "death":
			change_states("idle", "change_states")
			$ShootCD.stop()
			initialized = false
			$AnimationPlayer.play("Deactivate")
			#$Deactivate.start()
		

func _on_ShootCD_timeout():
	can_shoot = true
	
func on_hit(damage, _origin, _enemypos, _direction_hit):
	if state != "death":
		current_hp -= damage
	if current_hp <= 0:
			on_death()
			
func on_death():
	change_states("death", "on_death")
	#$RemoveTimer.start()
	$AnimationPlayer.play("Death")
	





func _on_RemoveTimer_timeout():
	queue_free()


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"Activate":
			change_states("laser", "animation_finished")
			$AnimationPlayer.play("Idle")
			
		"Attack_E", "Attack_W":
			$AnimationPlayer.play("Idle")
		"Deactivate":
			change_states("idle", "Animation_finished")
			can_activate = true


func change_states(new_state : String, caller : String) -> void:
	if state != "death":
		state = new_state
	print(caller)

func _on_LaserTimer_timeout():
	$ShootCD.start()
	$Laser.set_is_casting(false)
	laser_active = false
