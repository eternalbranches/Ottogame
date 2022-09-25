extends KinematicBody2D

export (int) var max_speed := 150
export (int) var speed_change := 150
export (int) var run_speed_change := 300
export (int) var max_run_speed := 500
export(int) var dash_speed := 700
var max_jump_speed := 150
var max_run_jump_speed := 425
export (int) var crawl_speed := 150
export (int) var jump_strenght := -500
export (int) var gravity := 1000
export (int) var walljump_height := -250
export (int) var walljump_power := 150
export (int) var second_jump_power := -400
export (int) var knockback_power := 300
export (int, 0, 200) var push = 400


export (float, 0, 1.0) var friction = 0.2
export (float, 0, 1.0) var friction_run = 0.03
export (float, 0, 1.0) var acceleration = 0.1

onready var animation_tree = get_node("AnimationTree")
onready var animation_mode = animation_tree.get("parameters/playback")

onready var runningsfx = preload("res://Assets/Soundtrack/SFX/running footsteps Otto.mp3")
onready var walkingsfx = preload("res://Assets/Soundtrack/SFX/otto walking sound.mp3")

var state := "idle"
var previous_state := "idle"

var velocity := Vector2.ZERO
var dash_up := false
var dash_side := false
var ceiling := false
var climbable := false
var ladder_location := 0.0
var invulnerable := false
var last_direction := "W"

var current_hp := 100
var max_hp := 100
var sword_damage := 20
var combo := false

var run_l := 0
var run_r := 0
var knockback := false
var bullettime := false
var can_jump := false
var can_doublejump := true
var started := false
var can_wallslide := true
var can_shoot := true
var can_shield := true
var run_released = true

var possible_targets = []
var current_target = null

signal death


func _ready():
	CharacterSave.ingame = true
	if CharacterSave.first_spawn == false:
		state = "rise"
		animation_mode.travel("Rise")
		
		

func get_input(delta):
	if CharacterSave.save_dict["running"] == true:
		if CharacterSave.controller == false:
			if Input.is_action_just_pressed("Right"):
				$"Dash-timer".start()
				if run_r == 1:
					state = "running"
				run_r += 1
			if Input.is_action_just_pressed("Left"):
				$"Dash-timer".start()
				if run_l == 1:
					state = "running"
				run_l += 1
		else:
			if Input.get_action_strength("Left") > 0.7:
				state = "running"
			if Input.get_action_strength("Right") > 0.7:
				state = "running"
	if Input.is_action_pressed("Right"):
		last_direction = "E"
		if velocity.x < 0:
			velocity.x += speed_change * delta
		if velocity.x < max_speed:
			velocity.x += speed_change *delta
	elif Input.is_action_pressed("Left"):
		last_direction = "W"
		if velocity.x > 0:
			velocity.x -= speed_change * delta
		if velocity.x > -max_speed:
			velocity.x -= speed_change *delta
	else:
		velocity.x = lerp(velocity.x, 0, friction)
	
	if velocity.x > 0 :
		animation_mode.travel("Walk_E")
	elif velocity.x <0:
		animation_mode.travel("Walk_W")
	if Input.is_action_just_pressed("Down"):
		set_collision_mask_bit(7,0)
		$PlatformTimer.start()
		
	
	if CharacterSave.save_dict["timeslow"] == true:
		if Input.is_action_just_pressed("Timeslow"):
			if bullettime == false:
				Engine.time_scale = 0.5
				bullettime = true
			else:
				Engine.time_scale = 1.0
				bullettime = false

func sfx_manager(audio : AudioStreamMP3) -> void:
	if $SFX.stream != null:
		$SFX.stream = audio
		

func idle_state(delta) -> void:
	get_input(delta)
	shooting()
	shield()
	action()
	call_deferred("sword_attack")
	if $SFX.stream != null:
		$SFX.stream = null
	if last_direction == "E":
		animation_mode.travel("Idle_E")
	else:
		animation_mode.travel("Idle_W")
	velocity.y += gravity * delta
	#velocity = move_and_slide(velocity, Vector2.UP)
	velocity = move_and_slide(velocity, Vector2.UP,
			false, 4, PI/4, false)
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("Falling"):
			collision.collider.fall()

	if Input.is_action_just_pressed("Jump"):
		velocity.y = jump_strenght
		state = "midair"
	elif (round(velocity.x)) != 0:
		if is_on_floor():
			state = "moving"
		else:
			state = "midair"
	if Input.is_action_just_pressed("Crawl"):
		if CharacterSave.save_dict["crawling"] == true:
			change_crawling()
			state = "crawling"
			
		
func running_state(delta) -> void:
	get_input_running(delta)
	shooting()
	action()
	shield()
	call_deferred("sword_attack")
	if $SFX.stream != runningsfx:
		$SFX.stream = runningsfx
		$SFX.play()
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP,
			false, 4, PI/4, false)
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("Pushable"):
			collision.collider.apply_central_impulse(-collision.normal * push)
		elif collision.collider.is_in_group("Falling"):
			collision.collider.fall()
	if Input.is_action_just_pressed("Jump"):
			velocity.y = jump_strenght
	if is_on_floor() == false:
		state = "midair_run"
	elif Input.is_action_just_pressed("Crawl"):
		change_crawling()
		state = "crawling"
		
		
func moving_state(delta) -> void:
	get_input(delta)
	shooting()
	action()
	shield()
	call_deferred("sword_attack")
	if $SFX.stream != walkingsfx:
		$SFX.stream = walkingsfx
		$SFX.play()
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP,
			false, 4, PI/4, false)
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("Falling"):
			collision.collider.fall()
	if $Wallcheck_E.is_colliding():
		if $Wallcheck_E.get_collider().is_in_group("Pushable") and last_direction == "E":
			state = "push"
			last_direction = "E"
	if $Wallcheck_W.is_colliding():
		if $Wallcheck_W.get_collider().is_in_group("Pushable") and last_direction == "W":
			state = "push"
			last_direction = "W"
	if Input.is_action_just_pressed("Jump"):
			velocity.y = jump_strenght
	if is_on_floor() == false:
		state = "midair"
	elif (round(velocity.x)) == 0:
		state = "idle"
	if CharacterSave.save_dict["crawling"] == true:
		if Input.is_action_just_pressed("Crawl"):
			change_crawling()
			state = "crawling"

func get_input_running(delta):
	#var dir = 0
	if Input.is_action_pressed("Right"):
		last_direction = "E"
		run_released = false
		if velocity.x < 0:
			velocity.x += run_speed_change *delta
		if velocity.x < max_run_speed:
			velocity.x += run_speed_change *delta
	elif Input.is_action_pressed("Left"):
		last_direction = "W"
		run_released = false
		if velocity.x > 0:
			velocity.x -= run_speed_change *delta
		if velocity.x > - max_run_speed:
			velocity.x -= run_speed_change *delta
	else:
		velocity.x = lerp(velocity.x, 0, friction_run)
	if Input.is_action_just_released("Right"):
		run_released = true
	if Input.is_action_just_released("Left"):
		run_released = true
	if run_released == true:
		if velocity.x < max_speed and velocity.x > -max_speed:
			state = "moving"
	
	if velocity.x > 0 :
		animation_mode.travel("Run_E")
	elif velocity.x <0:
		animation_mode.travel("Run_W")
		
	
	if CharacterSave.save_dict["running"] == true:
		if Input.is_action_just_pressed("Timeslow"):
			if bullettime == false:
				Engine.time_scale = 0.5
				bullettime = true
			else:
				Engine.time_scale = 1.0
				bullettime = false
			
	
	if Input.is_action_just_pressed("Down"):
		set_collision_mask_bit(7,0)
		$PlatformTimer.start()

func dash_state(_delta)-> void:
	if dash_side == false: 
		velocity.x = 0
	if dash_up == false:
		velocity.y = 0
	if $Dash_Timer.is_stopped() == true:
		$Dash_Timer.start()
		
	velocity = velocity.normalized()* dash_speed
	print(velocity, dash_speed)
	#print(velocity * dash_speed *10 * delta)
	move_and_slide(velocity)
	
	
func attack_state(delta) -> void:
	
	velocity.y += gravity * delta
	velocity.x = 0
	move_and_slide(velocity)
	
	
func crawling_state(delta) -> void:
	if $SFX.stream != null:
		$SFX.stream = null
	get_input_crawl()
	shooting()
	action()
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity /2, Vector2.UP,
			false, 4, PI/4, false)
	if velocity == Vector2.ZERO:
		animation_mode.travel("Crawling_E")
	if Input.is_action_just_pressed("Up") and ceiling == false:
			velocity.y = jump_strenght
	if is_on_floor() == false:
		change_standing()
		state = "midair"
	if Input.is_action_just_released("Crawl") and ceiling == false:
		change_standing()
		state = "idle"
	if $Ceilingcheck.get_overlapping_bodies().empty():
		ceiling = false
	else:
		ceiling = true
		
	
func get_input_crawl():
	velocity.x = 0
	if Input.is_action_pressed("Right"):
		animation_mode.travel("Crawling_E")
		velocity.x += crawl_speed
	if Input.is_action_pressed("Left"):
		animation_mode.travel("Crawling_W")
		velocity.x -= crawl_speed
		
func get_input_midair(delta):
#	var dir = 0
	if Input.is_action_pressed("Right"):
		if velocity.x < 0:
			velocity.x += speed_change *delta
		if velocity.x < max_jump_speed:
			velocity.x += speed_change *delta
	if Input.is_action_pressed("Left"):
		if velocity.x > - 0:
			velocity.x -= speed_change *delta
		if velocity.x > - max_jump_speed:
			velocity.x -= speed_change *delta
	check_wallslide()
	
	if velocity.x > 0 :
		animation_mode.travel("Jumping_E")
		last_direction = "E"
	elif velocity.x <0:
		animation_mode.travel("Jumping_W")
		last_direction = "W"
	doublejump()
			
func dash() -> void:
	if CharacterSave.save_dict["dash"] == true and can_doublejump == true:
		if Input.is_action_just_pressed("Dash") and Input.is_action_pressed("Up"):
			velocity.y = -dash_speed
			#velocity.y = clamp(velocity.y - dash_speed, -2000, -dash_speed*2)
			max_run_jump_speed = max_run_speed
			can_doublejump = false
			state = "dash"
			dash_up = true
		elif Input.is_action_just_pressed("Dash") and Input.is_action_pressed("Down"):
			#velocity.y = clamp(velocity.y + dash_speed, dash_speed, 800)
			velocity.y = dash_speed
			max_run_jump_speed = max_run_speed
			can_doublejump = false
			state = "dash"
			dash_up = true
		if Input.is_action_just_pressed("Dash") and Input.is_action_pressed("Left"):
			#velocity.x = clamp(velocity.x - dash_speed, -800, -dash_speed)
			velocity.x = -dash_speed
			max_run_jump_speed = max_run_speed
			can_doublejump = false
			state = "dash"
			dash_side = true
			animation_mode.travel("Dash_W")
			
		elif Input.is_action_just_pressed("Dash") and Input.is_action_pressed("Right"):
			#velocity.x = clamp(velocity.x + dash_speed, dash_speed, 800)
			velocity.x = dash_speed
			max_run_jump_speed = max_run_speed
			can_doublejump = false
			state = "dash"
			dash_side = true
			animation_mode.travel("Dash_E")


func doublejump ()-> void:
	if CharacterSave.save_dict["doublejump"] == true and can_doublejump == true:
		if Input.is_action_just_pressed("Jump"):
			velocity.y = jump_strenght
			print(velocity, "dash")
			max_jump_speed = max_speed
			can_doublejump = false


func get_input_midair_run(delta):
	if Input.is_action_pressed("Right"):
		if velocity.x < 0:
			velocity.x += run_speed_change * delta
		if velocity.x < max_run_jump_speed:
			velocity.x += run_speed_change * delta
	if Input.is_action_pressed("Left"):
		if velocity.x > - 0:
			velocity.x -= run_speed_change * delta
		if velocity.x > - max_run_jump_speed:
			velocity.x -= run_speed_change * delta
	check_wallslide()
			
	#if velocity.x > 0 :
	animation_mode.travel("Jumping_" + last_direction)
	doublejump()
		#last_direction = "E"
	#elif velocity.x <0:
	#	animation_mode.travel("Jumping_" + last_direction)
		#last_direction = "W"
		
func midair_state(delta):
	if $SFX.stream != null:
		$SFX.stream = null
	#if last_direction == "E":
	animation_mode.travel("Jumping_" +last_direction)
	#else:
	#	animation_mode.travel("Jumping_W")
	get_input_midair(delta)
	shooting()
	action()
	shield()
	dash()
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP,
			false, 4, PI/4, false)
	if is_on_floor():
		can_doublejump = true
		state = "moving"
		
func midair_run_state(delta):
	if $SFX.stream != null:
		$SFX.stream = null
	#if last_direction == "right":
	animation_mode.travel("Jumping_" + last_direction)
	#else:
	#	animation_mode.travel("Jumping_W")
	get_input_midair_run(delta)
	shooting()
	action()
	shield()
	dash()
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP,
			false, 4, PI/4, false)
	if is_on_floor():
		can_doublejump = true
		state = "running"
		run_released = true

func climbing_state(_delta) -> void:
	if $SFX.stream != null:
		$SFX.stream = null
	animation_mode.travel("Climbing")
	shooting()
	velocity = move_and_slide_with_snap(velocity, Vector2(0, 0))
	if Input.is_action_just_pressed("ActionButton"):
			velocity.y = jump_strenght
			state = "midair"
	if Input.is_action_pressed("Up"):
		velocity.y = -100
	if Input.is_action_pressed("Down"):
		velocity.y = 100
	if climbable == false:
		if velocity.y == -100:
			velocity.y = jump_strenght
		state = "midair"
		max_jump_speed = max_speed
		max_run_jump_speed = max_run_speed
		
func knockback_state(delta) -> void:
	if $SFX.stream != null:
		$SFX.stream = null
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP,
			false, 4, PI/4, false)
	if knockback == false:
		invulnerable = true
		Engine.time_scale = 1.0
		bullettime = false
		knockback = true
		yield(get_tree().create_timer(0.3), "timeout")
		#set_collision_mask_bit(2, 1)
		knockback = false
		invulnerable = false
		if state != "death":
			state = "midair"
			
func walljump_state(delta) -> void:
	if $SFX.stream != null:
		$SFX.stream = null
	velocity.y += gravity/3.0 * delta
	if last_direction == "E":
		velocity.x += 15
	else:
		velocity.x -= 15
	velocity = move_and_slide(velocity, Vector2.UP,
			false, 4, PI/4, false)
	if started == false:
		velocity.y = walljump_height
		if $Wallcheck_W.is_colliding() == true:
			velocity.x = walljump_power
			last_direction = "E"
			animation_mode.travel("Jumping_E")
		elif $Wallcheck_E.is_colliding() == true:
			velocity.x = -walljump_power
			last_direction = "W"
			animation_mode.travel("Jumping_W")
		started = true
		yield(get_tree().create_timer(0.28), "timeout")
		started = false
		if state == "walljump":
			change_state("midair")
	shooting()
	
func wallslide_state(delta):
	if $SFX.stream != null:
		$SFX.stream = null
	if velocity.y <= 0:
		velocity.y = 0
	shooting()
	if $Wallcheck_E.is_colliding() == false and $Wallcheck_W.is_colliding() == false:
		state = "midair"
	if is_on_floor():
		yield(get_tree().create_timer(0.2), "timeout")
		if state == "wallslide":
			state = "idle"
	elif velocity.y > 180:
		if state == "wallslide":
			can_wallslide = false
			state = "midair"
		yield(get_tree().create_timer(1), "timeout")
		can_wallslide = true
	
	velocity.y += 140 *delta
	velocity = move_and_slide(velocity, Vector2.UP,
			false, 4, PI/4, false)
	if Input.is_action_just_pressed("Down"):
		state = "midair"
		can_wallslide = false
		yield(get_tree().create_timer(1), "timeout")
		can_wallslide = true
	if Input.is_action_just_pressed("Jump"):
		state = "walljump"
		
func death_state(delta) -> void:
	if $SFX.stream != null:
		$SFX.stream = null
	animation_mode.travel("Death_" +last_direction)
	velocity.y += gravity * delta
	if is_on_floor():
		velocity.x = lerp(velocity.x, 0, friction)
	velocity = move_and_slide(velocity, Vector2.UP,
			false, 4, PI/4, false)
		
func rise_state(delta) -> void:
	if $SFX.stream != null:
		$SFX.stream = null
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP,
			false, 4, PI/4, false)
			
func push_state(delta) -> void:
	if $SFX.stream != null:
		$SFX.stream = null
	if last_direction == "W":
		if Input.is_action_pressed("Left"):
			velocity.x = -10
		if Input.is_action_just_pressed("Right") or $Wallcheck_W.is_colliding() == false:
			state = "idle"
	else:
		if Input.is_action_pressed("Right"):
			velocity.x = 10
		if Input.is_action_just_pressed("Left") or $Wallcheck_E.is_colliding() == false:
			state = "idle"
	velocity.y += gravity * delta
	#if last_direction == "left":
	animation_mode.travel("Push_" +last_direction)
	#else:
	#	animation_mode.travel("Push_E")
	velocity = move_and_slide(velocity, Vector2.UP,
			false, 4, PI/4, false)
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("Pushable"):
			collision.collider.apply_central_impulse(-collision.normal * push)
			
func _physics_process(delta):
	state_manager(delta)

func _process(_delta):
	$DebugState.text = state
	
func change_crawling():
	$CollisionStanding.disabled = true
	$CollisionCrawling.disabled = false
	
func change_standing():
	$CollisionStanding.disabled = false
	$CollisionCrawling.disabled = true

func action():
	if Input.is_action_just_pressed("ActionButton"):
		if climbable == true:
			velocity = Vector2.ZERO
			#global_position.y -= 8
			state = "climbing"
			global_position.x = ladder_location

func check_wallslide():
	if CharacterSave.save_dict["walljump"] == true:
		if is_on_wall() and can_wallslide == true:
			if $Wallcheck_W.is_colliding() == true and $Wallcheck_W.get_collider().is_in_group("Wallslideable"):
				state = "wallslide"
				can_doublejump = true
				velocity = Vector2.ZERO
				last_direction = "W"
				animation_mode.travel("Wallslide_W")
			if $Wallcheck_E.is_colliding() == true and $Wallcheck_E.get_collider().is_in_group("Wallslideable"):
				state = "wallslide"
				can_doublejump = true
				velocity = Vector2.ZERO
				last_direction = "E"
				animation_mode.travel("Wallslide_E")
func shooting():
	if CharacterSave.controller == true:
		if Input.is_action_just_pressed("Aim_assist"):
			possible_targets = $Aim_Assist.get_overlapping_bodies()
			if possible_targets.empty() == false:
				current_target = possible_targets[0]
				possible_targets.push_back(current_target)
				possible_targets.erase(current_target)
			else:
				current_target = null
	if CharacterSave.save_dict["gun"] == true and can_shoot == true:
		if Input.is_action_just_pressed("Shoot"):
			var skill = load("res://scenes/abilities/bullet.tscn")
			var skill_instance = skill.instance()
			if CharacterSave.controller == false:
				skill_instance.rotation = get_angle_to(get_global_mouse_position())
			else:
				if current_target != null:
					if $Aim_Assist.get_overlapping_bodies().has(current_target):
						skill_instance.rotation = get_angle_to(current_target.get_global_position())
					else:
						current_target = null
				else:
					if Input.is_action_pressed("Up"):
						skill_instance.rotation = -1.55
					elif last_direction == "E":
						skill_instance.rotation = 0
					elif last_direction == "W":
						#skill_instance.rotation = get_angle_to($AimPosition.get_global_position())
						skill_instance.rotation = -3.14
						#print(get_angle_to($AimPosition.get_global_position()))
			skill_instance.position = get_position()                   #get_node("TurnAxis/CastPoint").get_global_position()
			skill_instance.origin = "Player"
			$SFXPLayer.play()
			can_shoot = false
			$GunTimer.start()
			#skill_instance.node_reference = get_path()
			get_parent().add_child(skill_instance)
		

func shield():
		if CharacterSave.save_dict["shield"] == true and can_shield == true:
			if Input.is_action_just_pressed("Shield"):
				$Shield.visible = true
				$Shield.set_collision_mask_bit(4,1)
				$Shield/Selfdestruct.start()
				$Shield.animdirection(last_direction, $Shield_E.get_position(), $Shield_W.get_position())
#				var skill = load("res://Scenes/Abilities/Shield.tscn")
#				var skill_instance = skill.instance()
#				if CharacterSave.controller == false:
#					skill_instance.rotation = get_angle_to(get_global_mouse_position())
#					if last_direction == "left":
#						skill_instance.direction = "E"
#						skill_instance.set_global_position(get_node("Shield_E").get_global_position())
#					else:
#						skill_instance.direction = "W"
#						skill_instance.set_global_position(get_node("Shield_W").get_global_position())
#				else:
#					if current_target != null:
#						if $Aim_Assist.get_overlapping_bodies().has(current_target):
##							skill_instance.rotation = get_angle_to(current_target.get_global_position())
#						else:
#							current_target = null
#					else:
#						if Input.is_action_pressed("Up"):
#							skill_instance.rotation = -1.55
#						elif last_direction == "right":
#							skill_instance.direction = "E"
#							skill_instance.set_global_position(get_node("Shield_E").get_global_position())
#							
#						elif last_direction == "left":
#							skill_instance.direction = "W"
#							skill_instance.set_global_position(get_node("Shield_W").get_global_position())
#			skill_instance.origin = "Player"
				$SFXPLayer.play()
				can_shield = false
				$ShieldTimer.start()
			#skill_instance.node_reference = get_path()
#			get_parent().add_child(skill_instance)
			
func sword_attack():
	if Input.is_action_just_pressed("SwordAttack"):
		if velocity.x >= 300 or velocity.x <= -300:
			animation_mode.travel("SwordStab_"+last_direction)
		elif combo == false:
			animation_mode.travel("SwordLight_"+last_direction)
		else:
			animation_mode.travel("SwordLight_" +last_direction)
		change_state("attack")
	
	
func change_state(new_state) -> void:
	if state != "death":
		state = new_state

func state_manager(delta) -> void:
	call(state+"_state", delta)
		
func _on_Dashtimer_timeout() -> void:
	run_l = 0
	run_r = 0

func on_hit(damage, _origin, enemy_pos) -> void:
	if state != "death" and invulnerable == false:
		current_hp -= damage
		GameEvents.emit_signal_hp_change(current_hp, max_hp)
	if position.x < enemy_pos.x:
		velocity.x = -200
	else:
		velocity.x = +200
	velocity.y = 0
	velocity.y -= knockback_power
	
	if state != "death":
		state = "knockback"
		#set_collision_mask_bit(2, 0)
	if current_hp <= 0 and state != "death":
			on_death()

func on_heal(healamount) -> void:
	if state != "death":
		current_hp += healamount
		if current_hp > max_hp:
			current_hp = max_hp
		GameEvents.emit_signal_hp_change(current_hp, max_hp)
		$HealParticle.emitting = true
		
func on_death() -> void:
	state = "death"
	emit_signal("death")


func _on_Aim_Assist_body_entered(body):
	possible_targets.push_front(body)

func _on_Aim_Assist_body_exited(body):
	possible_targets.erase(body)


func _on_Aim_Assist_area_entered(area):
	possible_targets.push_front(area)


func _on_Aim_Assist_area_exited(area):
	possible_targets.erase(area)

func collect_powerup(PText):
	$Powerup.visible = true
	$Powerup.text = PText
	yield(get_tree().create_timer(5), "timeout")
	$Powerup.visible = false



func _on_GunTimer_timeout():
	can_shoot = true

func on_rise_finished():
	state = "idle"


func _on_PlatformTimer_timeout():
	set_collision_mask_bit(7, 1)


func _on_ShieldTimer_timeout():
	can_shield = true


func _on_ActivateEnemies_body_entered(body):
	body.player_enters_range(true)


func _on_ActivateEnemies_body_exited(body):
	body.player_enters_range(false)


func _on_Dash_Timer_timeout():
	dash_side = false
	dash_up = false
	state = "midair_run"


func _on_Hitbox_area_entered(area):
	print(area)
	if area.is_in_group("Enemy"):
		area.on_hit(sword_damage)
		
func attack_finished()-> void:
	change_state("idle")


func _on_Hitbox_body_entered(body):
	print(body)
	if body.is_in_group("Enemy"):
		body.on_hit(sword_damage, "player", get_global_position())
