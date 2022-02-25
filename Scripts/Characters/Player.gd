extends KinematicBody2D

export (int) var speed = 300
export (int) var jump_speed = -1000
export (int) var gravity = 3000

onready var animation_tree = get_node("AnimationTree")
onready var animation_mode = animation_tree.get("parameters/playback")

var state = "idle"
var previous_state = "idle"

var velocity = Vector2.ZERO

func get_input():
	velocity.x = 0
	if Input.is_action_pressed("Right"):
		animation_mode.travel("Walk_E")
		velocity.x += speed
	if Input.is_action_pressed("Left"):
		animation_mode.travel("Walk_W")
		velocity.x -= speed

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
		"midair":
			get_input()
			velocity.y += gravity * delta
			velocity = move_and_slide(velocity, Vector2.UP)
			if is_on_floor():
				state = "moving"
			




