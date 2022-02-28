extends RigidBody2D

var projectile_speed = 800
var damage
var origin
var direction
var life_time = 20
var dead := false
#var node_reference

var SFX_Impact





func _ready():
	if origin == "Player":
		$Area2D.set_collision_mask_bit(2, true)
	elif origin == "Enemy":
		$Area2D.set_collision_mask_bit(1, true)
	SelfDestruct()

	
	#var SFX = load("res://assets/sfx/"+skill_name+".wav")
	#SFX_Impact = load("res://assets/sfx/"+skill_name+"_Impact.wav")
	#get_node("AudioStreamPlayer2D").stream = SFX
	$AudioStreamPlayer2D.play()
	apply_impulse(Vector2(), Vector2(projectile_speed, 0).rotated(rotation))
	#SelfDestruct()

func _process(delta):
	if dead == false:
		$Smoketrail.add_point(global_position)
func SelfDestruct():
	yield(get_tree().create_timer(life_time), "timeout")
	queue_free()

func _on_Area2D_body_entered(body):
	get_node("AudioStreamPlayer2D").stream = SFX_Impact
	$AudioStreamPlayer2D.play()
	get_node("Area2D/CollisionShape2D").set_deferred("disabled", true)
	self.hide()
	$Light2D.enabled = false
	dead = true
	if body.is_in_group("Enemies"):
		body.OnHit(damage, origin)


func _on_Smoketrail_dead():
	dead = true
