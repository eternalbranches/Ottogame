extends KinematicBody2D

var state := "idle"
var max_hp := 50
var current_hp := 50
var current_direction := "W"
var spawn_position := 5.0
var velocity := Vector2.ZERO
var new_random_xpos := 0.0
var dead := false
var morale := 100
var threat := 0
var alert := false
var combat := false
var target
var investigate_pos: Vector2
var player_in_range := false

export (int) var gravity := 3000
export (float, 0, 1.0) var friction = 0.3
export (int) var speed := 200
export (int) var touch_damage := 1
export (int) var tail_damage := 5
#var initialized := false
var knockback := false
var last_seen := Vector2.ZERO
var can_tailattack_behind := true
var can_overhead_jumpattack := true
var can_tramplejump := true
var reset_started := false
var can_walk_E := false
var can_walk_W := false
var random_walk_x : float
var jumped := false

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	spawn_position = get_global_position().x
	$AnimationPlayer.play("Idle_" + current_direction)
	
	
	
func _process(_delta) -> void:
	floorcheck()
	$Label.text = state
	
	
func _physics_process(delta) -> void:
	
	match state:
		"idle":
			velocity.x = lerp(velocity.x, 0, friction)
			velocity.y += gravity * delta
			velocity = move_and_slide(velocity, Vector2.UP)
			if target:
				change_state("combat")
			elif $Idle_Walk.is_stopped():
				$Idle_Walk.start()
			$AnimationPlayer.play("Idle_" + current_direction)
			
		"alert":
			if current_direction == "E" and can_walk_E == true:
				velocity.x = speed /2.0
				#print("E")
			elif current_direction == "W" and can_walk_W == true:
				velocity.x = -speed/2.0
				#print("")
			else:
				velocity.x = 0

			velocity.x = lerp(velocity.x, 0, friction)
			velocity.y += gravity * delta
			velocity = move_and_slide(velocity, Vector2.UP)

			if velocity != Vector2(0,0):
				$AnimationPlayer.play("Walk_"+ current_direction)
			else:
				$AnimationPlayer.play("Idle_" + current_direction)
#
			if target:
				change_state("combat")
			
			
		"combat":
			sightcheck()
			if target == null:
				change_state("alert")
				return
			var remaining_distance_x = get_global_position().x - target.get_global_position().x
			var remaining_distance_y = get_global_position().y - target.get_global_position().y
			if target.position.x > position.x:
				current_direction = "E"
				
			elif target.position.x < position.x:
				current_direction = "W"
			
			if can_tramplejump:
				#print(remaining_distance)
				if remaining_distance_x > -180 and remaining_distance_x < -100:
					velocity.x = 0
					change_state("jump")
					can_tramplejump = false
					$AnimationPlayer.play("Jump_E")
					return
				elif remaining_distance_x < 180 and remaining_distance_x > 100:
					velocity.x = 0
					change_state("jump")
					can_tramplejump = false
					$AnimationPlayer.play("Jump_W")
					return
			if remaining_distance_x > -40 and remaining_distance_x < 40 and remaining_distance_y > -100 and remaining_distance_y < 100:
				
				velocity.x = 0
				change_state("tailattack")
			elif remaining_distance_x < -40:
				if can_walk_E == true:
					velocity.x = speed
				else:
					velocity.x = 0
					#change_state("tailattack")
			else:
				if can_walk_W == true:
					velocity.x = -speed
				else: 
					velocity.x = 0
					#change_state("tailattack")
			velocity.y += gravity * delta
			velocity = move_and_slide(velocity, Vector2.UP)
			
			if velocity != Vector2(0,0):
				$AnimationPlayer.play("Run_"+ current_direction)
			else:
				$AnimationPlayer.play("Idle_" + current_direction)
			
		"jump":
			velocity.y += gravity * delta
			velocity = move_and_slide(velocity, Vector2.UP)
			if is_on_floor() and jumped == true:
				change_state("combat")
				jumped = false
				$JumpTimer.start()
			
			
		"tailattack":
			if current_direction == "E":
				$AnimationPlayer.play("Tailattack_Overhead_"+current_direction)
			else:
				$AnimationPlayer.play("Tailattack_Overhead_"+current_direction)
		"death":
			velocity.x = 0
			velocity.y += gravity * delta
			velocity = move_and_slide(velocity, Vector2.UP)
		"knockback":
			velocity.y += gravity * delta
			velocity = move_and_slide(velocity, Vector2.UP)
			if knockback == false:
				knockback = true
				yield(get_tree().create_timer(1), "timeout")
				knockback = false
				change_state("alert")
		"chase":
			velocity.x = 0
			velocity.y += gravity * delta
			#var space_state = get_world_2d().direct_space_state
			#var sight_check = space_state.intersect_ray(position, player.position, [self], collision_mask)
			#sightcheck()
			$Label2.text = "gnn"
		#	if sight_check:
		#		if sight_check.collider.name == "Player" and player_in_range == true:
		#			print(sight_check)
		#			$Label2.text = "uhh"
		#			state = "shoot"
		#			$ChangeState.stop()
		#		elif sight_check.collider.name == "Player" and player_in_range == false:
		#			$Label2.text = "no"
		#			if $RayCast2D.is_colliding():
		#				if last_seen.x > position.x:
		##					velocity.x = speed
		#				if last_seen.x < position.x:
		#					velocity.x = -speed
		#		else: 
		#			if $RayCast2D.is_colliding():
		#				if last_seen.x > position.x:
		#					velocity.x = speed
		#				if last_seen.x < position.x:
		#					velocity.x = -speed
		#			if reset_started == false:
		#				print("reset")
		#				reset_started = true
		#				$ChangeState.start()
						
		#	velocity = move_and_slide(velocity, Vector2.UP)
		"return":
			var remaining_distance = get_global_position().x - spawn_position
			if remaining_distance > -10 and remaining_distance < 10:
				change_state("idle")
			if get_global_position().x < spawn_position:
				velocity.x = speed
			if get_global_position().x > spawn_position:
				velocity.x = -speed
			velocity.y += gravity * delta
			velocity = move_and_slide(velocity, Vector2.UP)
			
		"walk":
			#print(random_walk_x, "random_walk_x", get_global_position().x, "global_pos")
			var remaining_distance = get_global_position().x - random_walk_x
				
#			if remaining_distance > -40 and remaining_distance < 40:
#				velocity.x = 0
#			elif remaining_distance < -40:
#				if can_walk_E == true:
#					velocity.x = speed
#				else:
#					velocity.x = 0
#			else:
#				if can_walk_W == true:
#					velocity.x = -speed
#				else: 
#					velocity.x = 0
#			velocity.y += gravity * delta
#			velocity = move_and_slide(velocity, Vector2.UP)
#
#			if $AnimationPlayer.is_playing() == false:
#				$AnimationPlayer.play("Run_" + current_direction)
			#print (remaining_distance)
			if remaining_distance > 20:
				if can_walk_E == true:
					velocity.x = speed /2.0
					current_direction = "E"
				else:
					velocity.x = 0
			elif remaining_distance < -20: 
				#print("E")
				if can_walk_W == true:
					velocity.x = -speed/2.0
					current_direction = "W"
				else:
					velocity.x = 0
				#print("")
			else:
				velocity.x = 0

			velocity.x = lerp(velocity.x, 0, friction)
			velocity.y += gravity * delta
			velocity = move_and_slide(velocity, Vector2.UP)

			if velocity != Vector2(0,0):
				$AnimationPlayer.play("Walk_"+ current_direction)
			else:
				$AnimationPlayer.play("Idle_" + current_direction)
			
			if $Idle_Walk.is_stopped():
				$Idle_Walk.start()
			
func on_hit(damage, _origin, enemy_pos) -> void:
#	print("hit", damage)
	if state != "death":
		current_hp -= damage
		flash()
			
	#if position.x < enemy_posx:
	#	velocity.x += 200
	#else:
	#	velocity.x -= 200
	#velocity.y -= 200
	#state = "knockback"
	if investigate_pos == Vector2(0, 0):
		investigate_pos = Vector2(enemy_pos.x, 0)
		#current_direction = direction_hit
		#investigate(direction_hit)
	alert = true
	change_state("alert")
	
	if current_hp <= 0:
			on_death()
		
func on_death() -> void:
	change_state("death")
	dead = true
	set_collision_layer_bit(2, 0)
	set_collision_mask_bit(1,0)
	$AnimationPlayer.play("Death_" + current_direction)
	#$RemoveTimer.start()
	#for child in $Eyesight.get_children():
	#	child.enabled = false
	
	
func sightcheck():
	if target.state == "death":
		check_for_targets()
		print("Target died")
		if target == null:
			return
	var space_state = get_world_2d().direct_space_state
	var sight_check = space_state.intersect_ray(position, target.position, [self], collision_mask)
	if sight_check:
		if sight_check.collider != target:
			target = null
	#else:
	#	target = null



func _on_Hurtbox_body_entered(body) -> void:
	if body.is_in_group("Player"):
		body.on_hit(touch_damage, "enemy", position.x)


func _on_RemoveTimer_timeout() -> void:
	queue_free()

func flash():
	$Sprite.material.set_shader_param("flash_modifier", 0.4)
	$FlashTimer.start()

func _on_FlashTimer_timeout() -> void:
	$Sprite.material.set_shader_param("flash_modifier", 0)


func _on_ChangeState_timeout() -> void:
	change_state("return")
	reset_started = false

func _on_ShootAnim_timeout() -> void:
	change_state("combat")
	rng.randomize()
	var offset_x = rng.randf_range(-220, 220)
	new_random_xpos = get_global_position().x + offset_x
	
	
func _on_AI_Timer_timeout():
	pass
	
			
func investigate(direction_hit : String) -> void:
	current_direction = direction_hit
		
func change_state(new_state : String) -> void:
	#print( state, new_state)
	if state != "death":
		state = new_state
		
	match new_state:
		"alert":
			$Floorcheck_E.enabled = true
			$Floorcheck_W.enabled = true
			randomize()
			$Idle_Walk.wait_time = rand_range(1, 8)
			$Idle_Walk.start()
		"combat":
			$Floorcheck_E.enabled = true
			$Floorcheck_W.enabled = true
		"death":
			$Tailswipe/CollisionShape2D.disabled = true
			
			
			
			
			
			
func player_enters_range(in_range):
	if in_range == true:
		player_in_range = true
		#print("activate")
	else:
		player_in_range = false
		

	
func floorcheck() -> void:
	if state != "idle":
		if $Floorcheck_E.is_colliding() == true:
			can_walk_E = true
			#print($Floorcheck_E.get_collider())
		else:
			can_walk_E = false
		if $Floorcheck_W.is_colliding() == true:
			can_walk_W = true
			#print($Floorcheck_W.get_collider())
		else:
			can_walk_W = false


func _on_Vision_body_entered(body):
	if target == null and body.is_in_group("Dog") == false:
		target = body
	#	print(target)


func _on_AnimationPlayer_animation_finished(anim_name):
#	print(anim_name)
	match anim_name:
		"Tailattack_Overhead_W", "Tailattack_Overhead_E":
			change_state("combat")
			



func _on_Tailswipe_body_entered(body):
	if body.is_in_group("Dog") == false:
		body.on_hit(tail_damage, "dog", get_global_position())
		

func play_sfx(sfx : String) -> void:
	$SFX.stream = load(sfx)
	$SFX.play()

func check_for_targets() -> void:
	var possible_targets: Array = $Vision.get_overlapping_bodies()
	for body in possible_targets:
		if body.is_in_group("Dog"):
			possible_targets.erase(body)
	if possible_targets.size() > 0:
		target = possible_targets[0]
	else:
		target = null
	print(possible_targets, target)

func _on_Idle_Walk_timeout():
	
	random_walk_x = (get_global_position().x - rand_range(-200, 200))
	if state == "alert" or state == "idle":
		change_state("walk")
	elif state == "walk":
		change_state("idle")

func velocity_change(change : Vector2):
	jumped = true
	velocity = change


func _on_JumpTimer_timeout():
	can_tramplejump = true
