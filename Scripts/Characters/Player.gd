extends KinematicBody2D

export (int) var speed := 300
export (int) var crawl_speed := 150
export (int) var jump_speed := -1000
export (int) var gravity := 3000
export (int) var walljump_power := 300

onready var animation_tree = get_node("AnimationTree")
onready var animation_mode = animation_tree.get("parameters/playback")

var state := "idle"
var previous_state := "idle"

var velocity := Vector2.ZERO

var ceiling := false
var climbable := false
var invulnerable := false
var last_direction := "right"

var current_hp := 3
var max_hp := 3

var dash := 0
var knockback := false
var bullettime := false
var can_jump := false
var started := false

func get_input():
	velocity.x = 0
	if Input.is_action_just_pressed("Right"):
		$"Dash-timer".start()
		if dash == 1:
			velocity.x += speed*10
		dash += 1
	if Input.is_action_pressed("Right"):
		if state == "moving":
			animation_mode.travel("Walk_E")
		velocity.x += speed
		last_direction = "right"
	if Input.is_action_pressed("Left"):
		if state == "moving":
			animation_mode.travel("Walk_W")
		velocity.x -= speed
		last_direction = "left"
	
	if Input.is_action_just_pressed("Timeslow"):
				if bullettime == false:
					Engine.time_scale = 0.5
					bullettime = true
				else:
					Engine.time_scale = 1.0
					bullettime = false

func get_input_crawl():
	velocity.x = 0
	if Input.is_action_pressed("Right"):
		animation_mode.travel("Crawling_E")
		velocity.x += crawl_speed
	if Input.is_action_pressed("Left"):
		animation_mode.travel("Crawling_W")
		velocity.x -= crawl_speed
		
func get_input_midair():
	velocity.x = 0
	if Input.is_action_pressed("Right"):
		animation_mode.travel("Jumping_E")
		velocity.x += speed
		last_direction = "right"
		#if is_on_wall() and Input.is_action_just_pressed("Up"):
		#	state = "walljump"
		if is_on_wall():
			state = "wallslide"
			velocity = Vector2.ZERO
	if Input.is_action_pressed("Left"):
		animation_mode.travel("Jumping_W")
		velocity.x -= speed
		last_direction = "left"
		#if is_on_wall() and Input.is_action_just_pressed("Up"):
		#	state = "walljump"
		if is_on_wall():
			state = "wallslide"
			velocity = Vector2.ZERO
	

func _physics_process(delta):
	$Label.text = state
	match state:
		"idle":
			if last_direction == "right":
				animation_mode.travel("Idle_E")
			else:
				animation_mode.travel("Idle_W")
			get_input()
			shooting()
			action()
			velocity.y += gravity * delta
			velocity = move_and_slide(velocity, Vector2.UP)
			if Input.is_action_just_pressed("Up"):
				#if is_on_floor():
					velocity.y = jump_speed
					state = "midair"
			if velocity != Vector2.ZERO:
				if is_on_floor():
					state = "moving"
				else:
					state = "midair"
			if Input.is_action_just_pressed("Crawl"):
				change_crawling()
				state = "crawling"
			

				
		"moving":
			get_input()
			shooting()
			action()
			velocity.y += gravity * delta
			velocity = move_and_slide(velocity, Vector2.UP)
			if Input.is_action_just_pressed("Up"):
					velocity.y = jump_speed
					#if is_on_floor() == false: double jump
					#	state = "midair"
			if is_on_floor() == false:
				state = "midair"
			elif velocity == Vector2.ZERO:
				state = "idle"
			elif Input.is_action_just_pressed("Crawl"):
				change_crawling()
				state = "crawling"
			
		"midair":
			if last_direction == "right":
				animation_mode.travel("Jumping_E")
			else:
				animation_mode.travel("Jumping_W")
			get_input_midair()
			action()
			velocity.y += gravity * delta
			velocity = move_and_slide(velocity, Vector2.UP)
			if is_on_floor():
				state = "moving"
		"crawling":
			get_input_crawl()
			shooting()
			action()
			velocity.y += gravity * delta
			velocity = move_and_slide(velocity/2, Vector2.UP)
			if velocity == Vector2.ZERO:
				animation_mode.travel("Crawling_E")
			if Input.is_action_just_pressed("Up") and ceiling == false:
					change_standing()
					velocity.y = jump_speed
			if is_on_floor() == false:
				change_standing()
				state = "midair"
			if Input.is_action_just_released("Crawl") and ceiling == false:
				change_standing()
				state = "idle"
				#print($Ceilingcheck.get_overlapping_bodies())
			if $Ceilingcheck.get_overlapping_bodies().empty():
				ceiling = false
			else:
				ceiling = true
				
		"climbing":
			animation_mode.travel("Climbing")
			shooting()
			if Input.is_action_pressed("Up"):
				velocity.y = -100
			if Input.is_action_pressed("Down"):
				velocity.y = 100
			velocity = move_and_slide_with_snap(velocity, Vector2(0, 0))
			if Input.is_action_just_pressed("ActionButton"):
					velocity.y = jump_speed
					state = "midair"
			if climbable == false:
				velocity.y = jump_speed
				state = "midair"
				
		"knockback":
			velocity.y += gravity * delta
			velocity = move_and_slide(velocity, Vector2.UP)
			if knockback == false:
				invulnerable = true
				Engine.time_scale = 1.0
				bullettime = false
				knockback = true
				yield(get_tree().create_timer(1), "timeout")
				knockback = false
				invulnerable = false
				state = "midair"
				
		"walljump":
			velocity.y -= 15
			if last_direction == "left":
				velocity.x += 15
			else:
				velocity.x -= 15
			velocity = move_and_slide(velocity, Vector2.UP)
			if started == false:
				velocity.y = -200
				if last_direction == "left":
					velocity.x = 300
					animation_mode.travel("Jumping_E")
				else:
					velocity.x = -300
					animation_mode.travel("Jumping_W")
				started = true
				yield(get_tree().create_timer(0.5), "timeout")
				started = false
				state = "midair"
			
		"wallslide":
			if is_on_floor():
				state = "idle"
			elif velocity.y > 180:
				state = "midair"
			velocity.y += 100 *delta
			velocity = move_and_slide(velocity, Vector2.UP)
			if Input.is_action_just_pressed("Down"):
				state = "midair"
			if Input.is_action_just_pressed("Up"):
				state = "walljump"
			
		"death":
			velocity.y += gravity * delta
			velocity = move_and_slide(velocity, Vector2.UP)
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
func shooting():
	if Input.is_action_just_pressed("Shoot"):
		var skill = load("res://Scenes/Abilities/Bullet.tscn")
		var skill_instance = skill.instance()
		skill_instance.rotation = get_angle_to(get_global_mouse_position())
		skill_instance.position = get_position()                   #get_node("TurnAxis/CastPoint").get_global_position()
		skill_instance.origin = "Player"
		#skill_instance.node_reference = get_path()
		get_parent().add_child(skill_instance)
		


func _on_Dashtimer_timeout():
	dash = 0

func on_hit(damage, enemy_posx):
	if state != "death" and invulnerable == false:
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
