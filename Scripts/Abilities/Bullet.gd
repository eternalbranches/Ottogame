extends RigidBody2D

var projectile_speed = 500
var damage := 5
var origin
#var direction
var life_time = 20
var dead := false
var knockback := Vector2(50, 50)
#var enemyposx
#var node_reference

var SFX_Impact





func _ready():
	if origin == "Player":
		$Area2D.set_collision_mask_bit(2, true)
		$Area2D.set_collision_mask_bit(8, true)
	elif origin == "Enemy":
		$Area2D.set_collision_mask_bit(1, true)
		$Area2D.set_collision_mask_bit(2, true)
		
	SelfDestruct()

	
	#var SFX = load()
	SFX_Impact = load("res://Assets/Soundtrack/SFX/Futuristic Crossbow Shoot - Arrow Fly Zap Swish - 01    [002605].mp3")
	#get_node("AudioStreamPlayer2D").stream = SFX
	$AudioStreamPlayer2D.play()
	apply_impulse(Vector2(), Vector2(projectile_speed, 0).rotated(rotation))
	#SelfDestruct()

func _process(_delta):
	if dead == false:
		$Smoketrail.add_point(global_position)
func SelfDestruct():
	$DestructTimer.start()

func _on_Area2D_body_entered(body):
	if body.is_in_group("Enemy"):
		body.on_hit(damage, origin, get_global_position(), knockback)
	elif body.is_in_group("Player"):
		body.on_hit(damage, origin, get_global_position(), knockback)
	elif body.is_in_group("Destructable"):
		body.on_hit(damage)
	get_node("AudioStreamPlayer2D").stream = SFX_Impact
	$AudioStreamPlayer2D.play()
	get_node("Area2D/CollisionShape2D").set_deferred("disabled", true)
	self.hide()
	$Light2D.enabled = false
	dead = true
	
func _on_Area2D_area_entered(area):
	if area.is_in_group("Enemy"):
		area.on_hit(damage, origin, get_global_position(), knockback)
		
		get_node("AudioStreamPlayer2D").stream = SFX_Impact
		$AudioStreamPlayer2D.play()
		get_node("Area2D/CollisionShape2D").set_deferred("disabled", true)
		self.hide()
		$Light2D.enabled = false
		dead = true
func _on_Smoketrail_dead():
	dead = true


func _on_DestructTimer_timeout():
	queue_free()



