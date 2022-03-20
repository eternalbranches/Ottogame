extends KinematicBody2D

onready var animation_tree = get_node("AnimationTree")
onready var animation_mode = animation_tree.get("parameters/playback")
var velocity := Vector2.ZERO
var gravity := 3000
var fly_speed : = 1000
var state := "idle"

func _ready():
	pass # Replace with function body.
func _physics_process(delta):
	match state:
		"idle":
			velocity.x = 0
			velocity.y += gravity * delta
			velocity = move_and_slide(velocity, Vector2.UP)
		"heal":
			velocity.y += gravity * delta
			velocity = move_and_slide(velocity, Vector2.UP)
		"fly":
			velocity.x += fly_speed * delta
			velocity = move_and_slide(velocity, Vector2.UP)
			modulate.a -= 1*delta
			
func heal_animation():
	state = "heal"
	animation_mode.travel("Heal")
	
	
func heal_finished():
	state = "fly"
	animation_mode.travel("Fly")
	velocity.y = -60

func stop_flying():
	state = "idle"
	animation_mode.travel("Idle")
