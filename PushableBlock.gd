extends RigidBody2D
const pushspeed := 10000
var velocity := Vector2.ZERO
const gravity := 1000
func _ready():
	pass

func _on_PushzoneLeft_body_entered(body):
	pass

func _on_PushzoneRight_body_entered(body):
	pass
	
func push(pusher_position):
	if pusher_position > position:
		velocity.x = pushspeed
	if pusher_position < position:
		velocity.x = -pushspeed
	#velocity = move_and_slide(velocity, Vector2.UP)
	
	
func _process(delta):
	pass
	#if is_on_floor() == false:
	#	velocity.y += gravity * delta
	#velocity = move_and_slide(velocity, Vector2.UP)
