extends KinematicBody2D

var state := "idle"
var max_hp := 2
var current_hp := 2
var current_direction := "E"
var spawn_guardposition := 5
var velocity := Vector2.ZERO

export (int) var gravity := 3000
export (float, 0, 1.0) var friction = 0.3
export (int) var speed := 200
export (int) var touch_damage := 1
#var initialized := false
var knockback := false
var can_shoot := true
var reset_started := false
var player_in_range
onready var player = get_node("../../Player/Player")
var last_seen := Vector2.ZERO

var rng = RandomNumberGenerator.new()

onready var animation_tree = get_node("AnimationTree")
onready var animation_mode = animation_tree.get("parameters/playback")

func _ready():
	spawn_guardposition = get_global_position().x
	rng.randomize()
	var my_random_number = rng.randi_range(0, 10)
	#rng.randi_range(0, 5)
#rng.randf_range(-10.0, 10.0)
	print(my_random_number)
	
func _physics_process(delta):
	$Label.text = state
	match state:
		"idle":
			animation_mode.travel("Idle")
			velocity.x = lerp(velocity.x, 0, friction)
			velocity.y += gravity * delta
			velocity = move_and_slide(velocity, Vector2.UP)
		"sight":
			velocity.y += gravity * delta
			velocity = move_and_slide(velocity, Vector2.UP)
			sightcheck()
		"shoot":
			if player.position.x > position.x:
				current_direction = "E"
			elif player.position.x < position.x:
				current_direction = "W"
			velocity.x = 0
			velocity.y += gravity * delta
			velocity = move_and_slide(velocity, Vector2.UP)
			animation_mode.travel("Shoot_"+current_direction)
			sightcheck()
			#if initialized == false:
			#	$ShootCD.start()
			#	initialized = true
			if can_shoot == true and player_in_range:
				var skill = load("res://Scenes/Abilities/Bullet.tscn")
				var skill_instance = skill.instance()
				skill_instance.rotation = get_angle_to(player.get_global_position())
				skill_instance.position = get_position()                   #get_node("TurnAxis/CastPoint").get_global_position()
				skill_instance.enemyposx = position.x
				skill_instance.origin = "Enemy"
				#skill_instance.node_reference = get_path()
				$SFXPLayer.play()
				get_parent().add_child(skill_instance)
				$ShootCD.start()
				can_shoot = false
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
				if state != "death":
					state = "sight"
		"chase":
			velocity.x = 0
			velocity.y += gravity * delta
			#var space_state = get_world_2d().direct_space_state
			#var sight_check = space_state.intersect_ray(position, player.position, [self], collision_mask)
			sightcheck()
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
			if get_global_position().x < spawn_guardposition:
				velocity.x = speed
			if get_global_position().x > spawn_guardposition:
				velocity.x = -speed
			if round(get_global_position().x) == spawn_guardposition:
				state = "idle"
			velocity.y += gravity * delta
			velocity = move_and_slide(velocity, Vector2.UP)
		"reposition":
			pass
			
			
func on_hit(damage, _origin, enemy_posx):
	if state != "death":
		current_hp -= damage
		flash()
			
	if position.x < enemy_posx:
		velocity.x += 200
	else:
		velocity.x -= 200
	velocity.y = 0
	velocity.y -= 200
	state = "knockback"
	if current_hp <= 0:
			on_death()
		
func on_death():
	state = "death"
	animation_mode.travel("Death_" + current_direction)
	set_collision_layer_bit(2, 0)
	set_collision_mask_bit(1,0)
	$Hurtbox.queue_free()
	$RemoveTimer.start()
	
	
func sightcheck():
	var space_state = get_world_2d().direct_space_state
	var sight_check = space_state.intersect_ray(position, player.position, [self], collision_mask)
	if sight_check:
		if sight_check.collider.name == "Player":
			last_seen = player.position
			if state != "shoot":
				state = "shoot"
		else:
			#initialized = false
			state = "return"

func _on_ShootCD_timeout():
	can_shoot = true

func _on_Range_body_entered(body):
	if body.is_in_group("Player"):
		player_in_range = true
		$RayCast2D.enabled = true
		if state == "idle":
			state = "sight"
		elif state == "chase":
			$PositionTimer.start()

func _on_Range_body_exited(body):
	if body.is_in_group("Player"):
		player_in_range = false
		#initialized = false
		#if state != "death":
		#	state = "chase"


func _on_Hurtbox_body_entered(body):
	if body.is_in_group("Player"):
		body.on_hit(touch_damage, "enemy", position.x)


func _on_PositionTimer_timeout():
	state = "sight"
	player_in_range = true


func _on_RemoveTimer_timeout():
	queue_free()

func flash():
	$Sprite.material.set_shader_param("flash_modifier", 0.4)
	$FlashTimer.start()

func _on_FashTimer_timeout():
	$Sprite.material.set_shader_param("flash_modifier", 0)


func _on_ChangeState_timeout():
	state = "return"
	reset_started = false
