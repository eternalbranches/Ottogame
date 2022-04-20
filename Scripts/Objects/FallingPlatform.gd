extends KinematicBody2D

var worldposition := Vector2.ZERO
var fallstarted := false
var falling:= false
var velocity := Vector2.ZERO
export var gravity := 1500
func _ready():
	worldposition = get_position()
func fall():
	if fallstarted == false:
		$FallTimer.start()
		fallstarted = true
	
func _on_FallTimer_timeout():
	falling = true
	$RespawnTimer.start()
	
func _on_RespawnTimer_timeout():
	set_position(worldposition)
	fallstarted = false
	falling = false
	visible = true
	set_collision_layer_bit(7,1)
	set_collision_mask_bit(1, 0)
	set_collision_mask_bit(0, 0)
	
func _process(delta):
	if falling == true:
		velocity.y += gravity * delta
		velocity = move_and_slide(velocity, Vector2.UP)
		if is_on_floor() == true:
			visible = false
			set_collision_layer_bit(7,0)
			set_collision_mask_bit(1, 0)
			set_collision_mask_bit(0, 0)



