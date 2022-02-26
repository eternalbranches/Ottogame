extends KinematicBody2D

export (int) var speed = 300
export (int) var crawl_speed = 150
export (int) var jump_speed = -1000
export (int) var gravity = 3000

onready var animation_tree = get_node("AnimationTree")
onready var animation_mode = animation_tree.get("parameters/playback")

var state = "idle"
var previous_state = "idle"

var velocity = Vector2.ZERO

var ceiling = false

func get_input():
	velocity.x = 0
	if Input.is_action_pressed("Right"):
		animation_mode.travel("Walk_E")
		velocity.x += speed
	if Input.is_action_pressed("Left"):
		animation_mode.travel("Walk_W")
		velocity.x -= speed
		
func get_input_crawl():
	velocity.x = 0
	if Input.is_action_pressed("Right"):
		animation_mode.travel("Crawl_E")
		velocity.x += crawl_speed
	if Input.is_action_pressed("Left"):
		animation_mode.travel("Crawl_E")
		velocity.x -= crawl_speed

func _physics_process(delta):
	$Label.text = state
	match state:
		"idle":
			animation_mode.travel("Idle_E")
			get_input()
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
			elif Input.is_action_just_pressed("Crawl"):
				change_crawling()
				state = "crawling"
				
		"moving":
			get_input()
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
			get_input()
			velocity.y += gravity * delta
			velocity = move_and_slide(velocity, Vector2.UP)
			if is_on_floor():
				state = "moving"
		"crawling":
			get_input_crawl()
			velocity.y += gravity * delta
			velocity = move_and_slide(velocity/2, Vector2.UP)
			if velocity == Vector2.ZERO:
				animation_mode.travel("Crawl_E")
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
				
			
			
func change_crawling():
	$CollisionStanding.disabled = true
	$CollisionCrawling.disabled = false
	
func change_standing():
	$CollisionStanding.disabled = false
	$CollisionCrawling.disabled = true


