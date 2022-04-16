extends KinematicBody2D

onready var animation_tree = get_node("AnimationTree")
onready var animation_mode = animation_tree.get("parameters/playback")
var velocity := Vector2.ZERO
var gravity := 3000
var fly_speed : = 1000
var state := "idle"

onready var wings = preload("res://Assets/Soundtrack/SFX/wing flickering insect.mp3")

func _ready():
	pass
func _physics_process(delta):
	match state:
		"idle":
			if $SFX.stream != null:
				$SFX.stream = null
			velocity.x = 0
			velocity.y += gravity * delta
			velocity = move_and_slide(velocity, Vector2.UP)
		"heal":
			if $SFX.stream != null:
				$SFX.stream = null
			velocity.y += gravity * delta
			velocity = move_and_slide(velocity, Vector2.UP)
		"fly":
			if $SFX.stream != wings:
				$SFX.stream = wings
			velocity.x += fly_speed * delta
			velocity = move_and_slide(velocity, Vector2.UP)
			modulate.a -= 1*delta
			
func heal_animation():
	state = "heal"
	$AbilitySFX.play()
	animation_mode.travel("Heal")
	
	
func heal_finished():
	state = "fly"
	animation_mode.travel("Fly")
	velocity.y = -60

func stop_flying():
	state = "idle"
	animation_mode.travel("Idle")
