extends KinematicBody2D

var worldposition := Vector2.ZERO
var fallstarted := false
var fall:= false
var velocity := Vector2.ZERO
export var gravity := 1500
func _ready():
	worldposition = get_position()
func fall():
	if fallstarted == false:
		$FallTimer.start()
		fallstarted = true
	
func _on_FallTimer_timeout():
	fall = true
	$RespawnTimer.start()
	
func _on_RespawnTimer_timeout():
	set_position(worldposition)
	fallstarted = false
	fall = false
	visible = true
	set_collision_layer_bit(7,1)
	
func _process(delta):
	if fall == true:
		velocity.y += gravity * delta
		velocity = move_and_slide(velocity, Vector2.UP)
		if is_on_floor() == true:
			visible = false
			set_collision_layer_bit(7,0)



