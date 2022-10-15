extends KinematicBody2D

var target
var velocity := Vector2.ZERO
var speed : = 1

func _physics_process(delta : float) -> void:
	look_at(get_global_mouse_position())
	velocity -= (get_global_position() - get_global_mouse_position()) *delta
	move_and_collide((velocity /100) * speed)
	$Particles2D.rotation =  get_angle_to(get_global_mouse_position())
	
