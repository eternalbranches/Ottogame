extends KinematicBody2D

var state := "idle"
var max_hp := 2
var current_hp := 2
var current_direction := "E"
var velocity := Vector2.ZERO
export (int) var gravity := 3000
export (float, 0, 1.0) var friction = 0.3
export (int) var speed := 200
var initialized := false
var knockback := false
var can_shoot := true
var player_in_range
onready var player = get_node("../../Player/Player")
var last_seen := Vector2.ZERO

onready var animation_tree = get_node("AnimationTree")
onready var animation_mode = animation_tree.get("parameters/playback")

func _ready():
	pass
	

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
				get_parent().add_child(skill_instance)
				can_shoot = false
		"death":
			pass
		"knockback":
			velocity.y += gravity * delta
			velocity = move_and_slide(velocity, Vector2.UP)
			if knockback == false:
				knockback = true
				yield(get_tree().create_timer(1), "timeout")
				knockback = false
				state = "sight"
		"chase":
			velocity.y += gravity * delta
			velocity = move_and_slide(velocity, Vector2.UP)
			var space_state = get_world_2d().direct_space_state
			var sight_check = space_state.intersect_ray(position, player.position, [self], collision_mask)
			if sight_check:
				if sight_check.collider.name == "Player":
					if player.position.x > position.x:
						velocity.x = speed
					if player.position.x < position.x:
						velocity.x = -speed
			else:
				if last_seen.x > position.x:
					velocity.x = speed
				if last_seen.x < position.x:
					velocity.x = -speed
			
			
func on_hit(damage, origin, enemy_posx):
	print(position.x, " ",enemy_posx)
	if state != "death":
		current_hp -= damage
		
			
	if position.x < enemy_posx:
		velocity.x = -200
	else:
		velocity.x = +200
	velocity.y = 0
	velocity.y -= 1000
	state = "knockback"
	if current_hp <= 0:
			on_death()
		
func on_death():
	state = "death"
	
func sightcheck():
	var space_state = get_world_2d().direct_space_state
	var sight_check = space_state.intersect_ray(position, player.position, [self], collision_mask)
	if sight_check:
		if sight_check.collider.name == "Player":
			last_seen = player.position
			if state != "shoot":
				state = "shoot"
		else:
			initialized = false
			state = "sight"
			$ShootCD.stop()

func _on_ShootCD_timeout():
	can_shoot = true

func _on_Range_body_entered(body):
	if state == "idle":
		state = "sight"
		player_in_range = true
	elif state == "chase":
		yield(get_tree().create_timer(0.2), "timeout")
		state = "sight"
		player_in_range = true


func _on_Range_body_exited(body):
		player_in_range = false
		initialized = false
		if state != "death":
			state = "chase"
		$ShootCD.stop()
