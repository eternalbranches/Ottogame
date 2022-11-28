extends KinematicBody2D
var current_direction := "L"
var velocity := Vector2.ZERO
var speed := 100
var state := "idle"
var current_hp := 10
var dead := false
var active := false
var gravity := 500
var surface := "floor"
var surface_changed := false
var damage := 5.0
var knockback := Vector2(150, 150)
var invulnerable := false


func _ready() -> void:
	$Label.text = state
	$AnimationPlayer.play("Idle_"+current_direction)
	
func _physics_process(delta : float) -> void:
	state_manager(delta)

func _process(_delta):
	$Label.text = state
	$Label2.text = $AnimationPlayer.current_animation

func gravity_calc(delta)-> void:
	match surface:
		"floor":
			velocity.y += gravity * delta
		"wall_R":
			velocity.x += gravity * delta
		"wall_L":
			velocity.x -= gravity * delta
		"ceiling":
			velocity.y -= gravity * delta
			
func crawl_direction(_delta)-> void:
	match surface:
		"floor":
			if current_direction == "L":
				velocity.x = -50
			else:
				velocity.x = 50
		"wall_L":
			if current_direction == "L":
				velocity.y = -50
			else:
				velocity.y = 50
		"wall_R":
			if current_direction == "L":
				velocity.y = 50
			else:
				velocity.y = -50
		"ceiling":
			if current_direction == "L":
				velocity.x = 50
			else:
				velocity.x = -50

func state_manager(delta) -> void:
	call(state+"_state", delta)
	
func wall_check():
	if $Wallcheck.is_colliding():
		return true
	else:
		return false


func floor_check():
	if $Floorcheck.is_colliding():
		return true
	else:
		return false
	
func idle_state(_delta) -> void:
	pass
	
func death_state(delta) -> void:
	velocity.x = 0
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	
	
func falling_state(delta) -> void:
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	if is_on_floor():
		surface = "floor"
		change_state("crawl")
	
	
func crawl_state(delta) -> void:
	
	if wall_check() == true:
		change_state("climbing")
		
		match surface:
			"floor":
				$AnimationPlayer.play("Wall_Climb_"+current_direction)
			"wall_L":
				$AnimationPlayer.play("Wall_ClimbL_"+current_direction)
			"wall_R":
				$AnimationPlayer.play("Wall_ClimbR_"+current_direction)
			"ceiling":
				$AnimationPlayer.play("Ceiling_Climb_"+current_direction)
		return
	gravity_calc(delta)
	
	if floor_check() == true:
		crawl_direction(delta)
	elif surface_changed == false:
		if current_direction == "L":
			current_direction = "R"
			match surface:
				"floor":
					$AnimationPlayer.play("Crawl_R")
				"wall_L":
					$AnimationPlayer.play("Wall_Crawl_UP_R")
				"wall_R":
					$AnimationPlayer.play("Wall_Crawl_DOWN_R")
				"ceiling":
					$AnimationPlayer.play("Ceiling_Crawl_L")
				
		else:
			current_direction = "L"
			match surface:
				"floor":
					$AnimationPlayer.play("Crawl_L")
				"wall_L":
					$AnimationPlayer.play("Wall_Crawl_UP_L")
				"wall_R":
					$AnimationPlayer.play("Wall_Crawl_DOWN_L")
				"ceiling":
					$AnimationPlayer.play("Ceiling_Crawl_R")
					
		
		return
	
	velocity = move_and_slide(velocity, Vector2.UP)
		
func crawl_wall_R_state(_delta) -> void:
	pass
		
func climbing_state(_delta)-> void:
	pass
	
func change_state(new_state : String) -> void:
	#print( state, new_state)
	if state != "death":
		state = new_state
		$CollisionShape2D/Hurtbox.state = new_state
		
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
	set_collision_layer_bit(2, 0)
	set_collision_mask_bit(1,0)
	$CollisionShape2D/Hurtbox.state = "death"
	$AnimationPlayer.play("Death_" + current_direction)
	#$Floor.stop()
	
	
func flash():
	$Sprite.material.set_shader_param("flash_modifier", 0.4)
	$FlashTimer.start()

func _on_FlashTimer_timeout() -> void:
	$Sprite.material.set_shader_param("flash_modifier", 0)


func _on_Detect_body_entered(body):
	if active == true:
		print(body, "active")
		if body.is_in_group("Insect") == false:
			print(state)
			if state == "idle":
				$AnimationPlayer.play("Hatch_" + current_direction)
				print("hatch")
				#$Floor.start()
			
			

	


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"Hatch_R", "Hatch_L":
			change_state("falling")
			$Floorcheck.enabled = true
			$Wallcheck.enabled = true
			
			#print($Wallcheck.enabled, )
			
		"Wall_Climb_R":
			surface_change("wall_R")
			change_state("crawl")
			$AnimationPlayer.play("Wall_Crawl_UP_R")
			$Wallcheck.enabled = false
			surface_changed = true
			$Wall.start()
			
		"Wall_Climb_L":
			surface_change("wall_L")
			change_state("crawl")
			$AnimationPlayer.play("Wall_Crawl_UP_L")
			$Wallcheck.enabled = false
			surface_changed = true
			$Wall.start()
			
		"Wall_ClimbR_R":
			surface_change("ceiling")
			change_state("crawl")
			$AnimationPlayer.play("Ceiling_Crawl_L")
			$Wallcheck.enabled = false
			surface_changed = true
			$Wall.start()
		
		"Wall_ClimbL_L":
			surface_change("ceiling")
			change_state("crawl")
			$AnimationPlayer.play("Ceiling_Crawl_R")
			$Wallcheck.enabled = false
			surface_changed = true
			$Wall.start()
			
		"Wall_ClimbL_R":
			surface_change("floor")
			change_state("crawl")
			$AnimationPlayer.play("Crawl_R")
			$Wallcheck.enabled = false
			surface_changed = true
			$Wall.start()
			
		"Wall_ClimbR_L":
			surface_change("floor")
			change_state("crawl")
			$AnimationPlayer.play("Crawl_L")
			$Wallcheck.enabled = false
			surface_changed = true
			$Wall.start()
			
		"Ceiling_Climb_L":
			surface_change("wall_R")
			change_state("crawl")
			$AnimationPlayer.play("Wall_Crawl_DOWN_R")
			$Wallcheck.enabled = false
			surface_changed = true
			$Wall.start()
			
		"Ceiling_Climb_R":
			surface_change("wall_L")
			change_state("crawl")
			$AnimationPlayer.play("Wall_Crawl_DOWN_L")
			$Wallcheck.enabled = false
			surface_changed = true	
			$Wall.start()
			
		"Death_R", "Death_L":
			queue_free()
	
func surface_change(new_surface : String)->void:
	surface = new_surface
	

#func _on_Floor_timeout():
#	if is_on_floor():
#		if $Floorcheck.is_colliding() == false:
#			if current_direction == "L":
#				current_direction = "R"
#			else:
#				current_direction = "L"
#		elif is_on_wall():
#			if current_direction == "L":
#				current_direction = "R"
#			else:
#				current_direction = "L"
#		$AnimationPlayer.play("Crawl_"+current_direction)


func _on_Wall_timeout():
	$Wallcheck.enabled = true
	surface_changed = false
	


func _on_Hurtbox_body_entered(body):
	if body.is_in_group("Insect") == false:
		if body.is_in_group("Enemy") or body.is_in_group("Player"):
			body.on_hit(damage, "larvae", get_global_position(), knockback)
