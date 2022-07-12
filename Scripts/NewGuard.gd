extends KinematicBody2D

onready var animation_tree = get_node("AnimationTree")
onready var animation_mode = animation_tree.get("parameters/playback")

var state := "idle"
var max_hp := 2
var current_hp := 2
var current_direction := "W"
var spawn_guardposition := 5.0
var velocity := Vector2.ZERO
var new_random_xpos := 0.0
var dead := false
var in_sight := {"Mutants": [], "Projectiles": []}
var in_memory := {"Guards": [], "Mutants": [], "Projectiles": []}
var morale := 100
var threat := 0
var alert := false
var combat := false
var target
var investigate_pos: Vector2
var player_in_range := false
var last_seen := Vector2.ZERO
var knockback := false
var can_shoot := true
var reset_started := false
var can_walk_E := false
var can_walk_W := false

export var group := 1
export (int) var gravity := 3000
export (float, 0, 1.0) var friction = 0.3
export (int) var speed := 200
export (int) var touch_damage := 1
#var initialized := false

#onready var player = get_node("../../Player/Player")


var rng = RandomNumberGenerator.new()


func _ready():
	spawn_guardposition = get_global_position().x
	add_to_group("guard_" + str(group))
	#rng.randi_range(0, 5)
#rng.randf_range(-10.0, 10.0)
func _process(_delta):
	if state != "idle":
		floorcheck()

func _physics_process(delta):
	$Label.text = state
	state_manager(delta)


func state_manager(delta):
	match state:
		"idle":
			idle_state(delta)
			
		"alert":
			alert_state(delta)
			
		"combat":
			combat_state(delta)
			
		"shoot":
			shoot_state()
			
		"death":
			death_state(delta)
			
		"knockback":
			knockback_state(delta)
			
		"return":
			return_state(delta)

func idle_state(delta):
	animation_mode.travel("Idle_"+ current_direction)
	velocity.x = lerp(velocity.x, 0, friction)
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	
func alert_state(delta):
	if current_direction == "E" and can_walk_E == true:
		velocity.x = speed / 2.0
		#print("E")
		animation_mode.travel("Walk_"+ current_direction)
	elif current_direction == "W" and can_walk_W == true:
		velocity.x = -speed/2.0
		animation_mode.travel("Walk_"+ current_direction)
		#print("")
	else:
		velocity.x = 0.0
		animation_mode.travel("Idle_"+ current_direction)
	
	velocity.x = lerp(velocity.x, 0, friction)
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	
func combat_state(delta):
	if target == null:
		state = "alert"
		return
	var remaining_distance = get_global_position().x - new_random_xpos
	if target.position.x > position.x:
		current_direction = "E"
	elif target.position.x < position.x:
		current_direction = "W"
	if remaining_distance > -5 and remaining_distance < 5:
		velocity.x = 0
	elif remaining_distance < -5:
		if can_walk_E == true:
			velocity.x = speed
		else:
			velocity.x = 0
	else:
		if can_walk_W == true:
			velocity.x = -speed
		else: 
			velocity.x = 0
	animation_mode.travel("Walk_"+ current_direction)
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if in_sight["Mutants"].empty() == false:
		if can_shoot == true:
			change_state("shoot")
	else:
		change_state("alert")

func shoot_state():
	if can_shoot == true:
		can_shoot = false
		#rng.randomize()
		#var numberanimation = rng.randi_range(1, 2)
		#print(numberanimation)
		animation_mode.travel("Shoot_"+current_direction + str(1))
		$ShootCD.start()
		$ShootAnim.start()
		
func death_state(delta):
	velocity.x = 0
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	
func knockback_state(delta):
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	if knockback == false:
		knockback = true
		yield(get_tree().create_timer(1), "timeout")
		knockback = false
		change_state("alert")
		
func return_state(delta):
	var remaining_distance = get_global_position().x - spawn_guardposition
	if remaining_distance > -10 and remaining_distance < 10:
		change_state("idle")
	if get_global_position().x < spawn_guardposition:
		velocity.x = speed
	if get_global_position().x > spawn_guardposition:
		velocity.x = -speed
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)

func suprised_state(delta):
	pass


func on_hit(damage, _origin, enemy_pos, direction_hit) -> void:
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
		current_direction = direction_hit
		#investigate(direction_hit)
	alert = true
	change_state("alert")
	
	if current_hp <= 0:
			on_death()
		
func on_death() -> void:
	change_state("death")
	dead = true
	animation_mode.travel("Death_" + current_direction)
	set_collision_layer_bit(8, 0)
	set_collision_mask_bit(1,0)
	$RemoveTimer.start()
	for child in $Eyesight.get_children():
		child.enabled = false
	
	
#func sightcheck():
#	var space_state = get_world_2d().direct_space_state
#	var sight_check = space_state.intersect_ray(position, player.position, [self], collision_mask)
#	if sight_check:
#		if sight_check.collider.name == "Player":
#			last_seen = player.position
#			if state == "sight" or "return":
#				state = "combat"
#		else:
#			state = "return"

func _on_ShootCD_timeout() -> void:
	can_shoot = true



func _on_Hurtbox_body_entered(body) -> void:
	if body.is_in_group("Player"):
		body.on_hit(touch_damage, "enemy", position.x)



func _on_RemoveTimer_timeout() -> void:
	queue_free()

func flash():
	$Sprite.material.set_shader_param("flash_modifier", 0.4)
	$FlashTimer.start()

func _on_FashTimer_timeout() -> void:
	$Sprite.material.set_shader_param("flash_modifier", 0)


func _on_ChangeState_timeout() -> void:
	change_state("return")
	reset_started = false

func _on_ShootAnim_timeout() -> void:
	change_state("combat")
	rng.randomize()
	var offset_x = rng.randf_range(-220, 220)
	new_random_xpos = get_global_position().x + offset_x
	
func create_bullet() -> void:
	randomize()
	var random_vector = Vector2(rand_range(-50.0 , 50.0), rand_range(-50.0 , 50.0))
	var skill = load("res://scenes/abilities/bulletlaser.tscn")
	var skill_instance = skill.instance()
	skill_instance.rotation = get_angle_to(target.get_global_position() + random_vector)
	skill_instance.position = $Bulletpoint.get_global_position()                  #get_node("TurnAxis/CastPoint").get_global_position()
	skill_instance.enemyposx = position.x
	skill_instance.origin = "Enemy"
	#skill_instance.node_reference = get_path()
	$SFXPLayer.play()
	get_parent().add_child(skill_instance)
	create_noise("medium")
	
func create_noise(volume) -> void:
	var noise = load("res://scenes/abstract/"+volume+"noise.tscn")
	var noise_instance = noise.instance()
	noise_instance.position = get_global_position()
	get_parent().add_child(noise_instance)


func _on_SightTimer_timeout() -> void:
	for key in in_sight:
		in_sight[key].resize(0)
	for child in $Eyesight.get_children():
	#	child.enabled = true
		if child.is_colliding():
			#print(child.get_collider())
			if child.get_collider().is_in_group("Mutant") and in_sight["Mutants"].has(child.get_collider()) == false:
				in_sight["Mutants"].push_back(child.get_collider())
				add_memory(child.get_collider(), "Mutants")
				if alert == false:
					alert = true
					investigate_pos = child.get_global_position()
					_on_AI_Timer_timeout()
				print("spotted mutant")
			elif child.get_collider().is_in_group("Projectiles") and in_sight["Projectiles"].has(child.get_collider()) == false:
				in_sight["Projectiles"].push_back(child.get_collider())
				add_memory(child.get_collider(), "Projectiles")
				if alert == false:
					alert = true
				print("spotted projectile")
		
		
func add_memory(new_memory, category):
	if in_memory[category].has(new_memory) == false:
		in_memory[category].push_back(new_memory)
		call_ally(new_memory, category)
		
	
func call_ally(memory, category):
	get_tree().call_group("guard_"+ str(group), "hear_ally", memory, category)
		
func hear_ally(memory, category):
	add_memory(memory, category)
	if alert == false:
		alert = true
	_on_AI_Timer_timeout()
	
	
func _on_AI_Timer_timeout():
	if alert == true and dead == false:
		if in_memory["Mutants"].empty() == false:
			combat = true
			target = in_memory["Mutants"][0]
			if in_sight["Mutants"].has(target) == false:
				investigate_pos = target.get_global_position()
		elif in_memory["Projectiles"].empty() == false:
			change_state("alert")
		elif investigate_pos != null:
			change_state("alert")
		if combat == true and state != "shoot":
			change_state("combat")
			
func investigate(direction_hit) -> void:
	current_direction = direction_hit
		
func change_state(new_state) -> void:
	#print( state, new_state)
	if state != "death":
		state = new_state
	match new_state:
		"alert":
			$Floorcheck_E.enabled = true
			$Floorcheck_W.enabled = true
			
func player_enters_range(in_range):
	if in_range == true:
		player_in_range = true
		$SightTimer.set_wait_time(0.3)
		print("activate")
	else:
		player_in_range = false
		$SightTimer.set_wait_time(10)
		

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
			
func heard_sound(volume : String, sound_position : Vector2):
	match volume:
		"loud":
			alert = true
			investigate_pos = sound_position
			_on_AI_Timer_timeout()
		"medium":
			alert = true
			investigate_pos = sound_position
			_on_AI_Timer_timeout()
		"small":
			if alert == false: 
				if sound_position.x > get_global_position().x:
					current_direction = "E"
				else:
					current_direction = "W"
				
