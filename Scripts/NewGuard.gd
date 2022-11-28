extends KinematicBody2D

onready var animation_tree = get_node("AnimationTree")
#onready var animation_mode = animation_tree.get("parameters/playback")

var state := "idle"
var max_hp := 15
var current_hp := 15
var current_direction := "W"
var spawn_guardposition := 5.0
var velocity := Vector2.ZERO
var jumppower := 1000
var can_jump := true
var new_random_xpos := 0.0
var dead := false
var in_memory := {"Guards": [], "Mutants": [], "Projectiles": []}
var morale := 100
var threat := 0
var alert := false
var combat := false
var ammo := 3
var target
var investigate_pos: Vector2
var player_in_range := false
var knockback := false
var can_shoot := true
var reset_started := false
var can_walk_E := false
var can_walk_W := false
var near_wall_E := false
var near_wall_W := false
var invulnerable := false

export var group := 1
export (int) var gravity := 3000

export (float, 0, 1.0) var friction = 0.3
export (int) var speed := 300
export (int) var touch_damage := 1
export var debug := false
#var initialized := false

#onready var player = get_node("../../Player/Player")


var rng = RandomNumberGenerator.new()


func _ready():
	spawn_guardposition = get_global_position().x
	add_to_group("guard_" + str(group))
	
	
func _process(_delta):
	$Label.text = state
	
	
func _physics_process(delta):
	state_manager(delta)


func state_manager(delta) -> void:
	call(state+"_state", delta)


func idle_state(delta):

	velocity.x = lerp(velocity.x, 0, friction)
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	$AnimationPlayer.play("Idle_" + current_direction)
#	animation_mode.travel("Idle_"+ current_direction)
	if target:
		change_state("combat", "idle_state")
	
	
func alert_state(delta) -> void:
	velocity.x = lerp(velocity.x, 0, friction)
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	floorcheck()
	$AnimationPlayer.play("Idle_" + current_direction)
	#animation_mode.travel("Idle_"+ current_direction)
	if target:
		$AnimationPlayer.play("Prepare_Shoot_" + current_direction)
		change_state("combat", "idle_state")
	
func jump_state(delta) -> void:
	if current_direction == "E":
		velocity.x = speed
	else:
		velocity.x = -speed
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	if is_on_floor() == true:
		change_state("alert", "jump_state")
	
	
func combat_state(delta) -> void:
	sightcheck()
	floorcheck()
	if target == null:
		change_state("alert", "combat_state")
		return
		
	if target.get_global_position().x > get_global_position().x:
		current_direction = "E"
		#print(can_walk_E, can_walk_W, get_global_position().distance_to(target.get_global_position()))
		if can_walk_W and get_global_position().distance_to(target.get_global_position()) < 200:
			velocity.x = -50
			
		elif can_walk_E and get_global_position().distance_to(target.get_global_position()) > 350:
			velocity.x = 50
		else:
			velocity.x = lerp(velocity.x, 0, friction)
	else:
		current_direction = "W"
		if can_walk_E and get_global_position().distance_to(target.get_global_position()) < 200:
			velocity.x = 50
		elif can_walk_W and get_global_position().distance_to(target.get_global_position()) > 350:
			velocity.x = -50
		else:
			velocity.x = lerp(velocity.x, 0, friction)
	#print(velocity)
	if velocity > Vector2(1,0) or velocity < Vector2(-1,0):
		$AnimationPlayer.play("Walk_" + current_direction)
		#animation_mode.travel("Walk_"+ current_direction)
	else:
		$AnimationPlayer.play("Idle_" + current_direction)
		#animation_mode.travel("Idle_"+ current_direction)
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if can_shoot:
		change_state("shoot", "combat_state")
		$AnimationPlayer.play("Prepare_Shoot_"+ current_direction)
		can_shoot = false
	

func shoot_state(delta) -> void:
	velocity.x = 0
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
#	if can_shoot == true:
#		can_shoot = false
#		#rng.randomize()
#		#var numberanimation = rng.randi_range(1, 2)
#		$AnimationPlayer.play("Shoot_" + current_direction + str(1))
#		#animation_mode.travel("Shoot_"+current_direction + str(1))
#
#		$ShootAnim.start()
		
func death_state(delta) -> void:
	velocity.x = 0
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	
	
func knockback_state(delta) -> void:
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	if knockback == false:
		knockback = true
		yield(get_tree().create_timer(1), "timeout")
		knockback = false
		change_state("alert", "knockback_state")
		
		
func return_state(delta : float) -> void:
	var remaining_distance = get_global_position().x - spawn_guardposition
	if remaining_distance > -10 and remaining_distance < 10:
		change_state("idle", "return_state")
	if get_global_position().x < spawn_guardposition:
		velocity.x = speed
	if get_global_position().x > spawn_guardposition:
		velocity.x = -speed
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)

func suprised_state(_delta):
	pass


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
	if investigate_pos == Vector2(0, 0):
		investigate_pos = enemy_pos
		#investigate(direction_hit)
	alert = true
	change_state("alert", "on_hit")
	if target == null:
		if enemy_pos > get_global_position():
			current_direction = "E"
		else:
			current_direction = "W"
		
func on_death() -> void:
	change_state("death", "on_death")
	dead = true
	$AnimationPlayer.play("Death_" + current_direction)
	#animation_mode.travel("Death_" + current_direction)
	set_collision_layer_bit(8, 0)
	set_collision_mask_bit(1,0)
	$RemoveTimer.start()
	
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
	change_state("return", "change_state_timeout")
	reset_started = false

func _on_ShootAnim_timeout() -> void:
	change_state("combat", "shootanim_timeout")
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
	#skill_instance.enemyposx = position.x
	skill_instance.origin = "Enemy"
	#skill_instance.node_reference = get_path()
	$SFXPLayer.play()
	get_parent().add_child(skill_instance)
	create_noise("medium")
	ammo -= 1

	
func create_noise(volume) -> void:
	var noise = load("res://scenes/abstract/"+volume+"noise.tscn")
	var noise_instance = noise.instance()
	noise_instance.position = get_global_position()
	get_parent().add_child(noise_instance)

				
		
func jump(direction) -> void:
	velocity.y = -jumppower
	if direction == "E":
		velocity.x = speed
	else:
		velocity.x = -speed
	can_jump = false
	$JumpCD.start()
	

func add_memory(new_memory, category, firsthand) -> void:
	if in_memory[category].has(new_memory) == false:
		in_memory[category].push_back(new_memory)
		if firsthand == true:
			call_ally(new_memory, category)
		
	
func call_ally(memory, category) -> void:
	get_tree().call_group("guard_"+ str(group), "hear_ally", memory, category)
	
		
func hear_ally(memory, category) -> void:
	add_memory(memory, category, false)
	if alert == false:
		alert = true
	
			
func investigate(direction_hit) -> void:
	current_direction = direction_hit
		
		
func change_state(new_state, _caller) -> void:
	#if debug == true:
		#print(caller)
	if state != "death":
		state = new_state
	match new_state:
		"alert":
			$Floorcheck_E.enabled = true
			$Floorcheck_W.enabled = true
			$Wallcheck_E.enabled = true
			$Wallcheck_W.enabled = true
			
			
func player_enters_range(in_range : bool) -> void:
	if in_range == true:
		player_in_range = true
		#$SightTimer.set_wait_time(0.3)
	else:
		player_in_range = false
		#$SightTimer.set_wait_time(10)
		

func floorcheck() -> void:
	if state != "idle":
		if $Floorcheck_E.is_colliding() == true and $Wallcheck_E.is_colliding() == false:
			can_walk_E = true
		else:
			can_walk_E = false
		if $Floorcheck_W.is_colliding() == true and $Wallcheck_W.is_colliding() == false:
			can_walk_W = true
		else:
			can_walk_W = false
			
			
func heard_sound(volume : String, sound_position : Vector2) -> void:
	match volume:
		"loud":
			alert = true
			investigate_pos = sound_position
		"medium":
			alert = true
			investigate_pos = sound_position
		"small":
			if alert == false: 
				if sound_position.x > get_global_position().x:
					current_direction = "E"
				else:
					current_direction = "W"
				
				
func new_random_position() -> void:
	randomize()
	var random_offset = rng.randf_range(-30.0, 30.0)
	new_random_xpos = get_global_position().x + random_offset
	

func sightcheck():
#	if get_node_or_null(get_path_to(target)):
	if target.state == "death":
		target = null
		return
	print(target)
	var space_state = get_world_2d().direct_space_state
	var sight_check = space_state.intersect_ray(position, target.get_global_position(), [self], collision_mask, true, true)
	#$Line2D.add_point(position)
	#$Line2D.add_point(target.get_global_position())
	if sight_check:
		print(sight_check.collider)
		if sight_check.collider != target:
			target = null
	#intersect_ray(from: Vector2, to: Vector2, exclude: Array = [  ], collision_layer: int = 0x7FFFFFFF, collide_with_bodies: bool = true, collide_with_areas: bool = false)


func _on_JumpCD_timeout() -> void:
	can_jump = true


func _on_Vision_body_entered(body):
	if target == null and body.is_in_group("Guard") == false:
		target = body
func _on_Vision_area_entered(area):
	if target == null and area.is_in_group("Guard") == false:
		target = area


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"Prepare_Shoot_E", "Prepare_Shoot_W":
			if target.get_global_position().x > get_global_position().x:
				current_direction = "E"
			else:
				current_direction = "W"
			$AnimationPlayer.play("Shoot_"+current_direction)
		"Shoot_E" , "Shoot_W":
			if ammo > 0:
				if target != null:
					if target.get_global_position().x > get_global_position().x:
						current_direction = "E"
					else:
						current_direction = "W"
				$AnimationPlayer.play("Shoot_" +current_direction)
			elif state == "shoot":
				change_state("alert", "create_bullet")
				ammo = 3
				$ShootCD.start()
				
				

			
			
			
#	if ammo == 0:
#		if state == "shoot":
#			change_state("alert", "create_bullet")
#			ammo = 3



